//
//  AddRemindersInteractor.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-25.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import CoreData
import NotificationCenter

extension UIColor { // For some reason this does not work when putting it in another file
    func getHueValues() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alpha: CGFloat = 0
        self.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        return (hue, sat, bri, alpha)
    }
}

extension HueColor { // For some reason this does not work when putting it in another file
    static func create(context: NSManagedObjectContext, color: UIColor) -> HueColor {
        let hueColor = HueColor(context: context)
        let (hue, sat, bri, alpha) = color.getHueValues()
        hueColor.hue = Float(hue)
        hueColor.saturation = Float(sat)
        hueColor.brightness = Float(bri)
        hueColor.alpha = Float(alpha)
        return hueColor
    }
}

protocol AddReminderInteracting {
    func add(managedObjectContext: NSManagedObjectContext,
             name: String,
             color: UIColor,
             day: Int16,
             time: Date,
             bridge: HueBridge,
             lightIDs: Set<String>,
             completion: @escaping (Bool) -> Void)
    func toggleLightSelectedState(_ viewModel: NewReminderViewModel,
                                  lightID: String)
    func select(bridge: HueBridge, _ viewModel: NewReminderViewModel)
}

class AddReminderInteractor: AddReminderInteracting {
    func add(managedObjectContext: NSManagedObjectContext,
             name: String,
             color: UIColor,
             day: Int16,
             time: Date,
             bridge: HueBridge,
             lightIDs: Set<String>,
             completion: @escaping (Bool) -> Void) {
        var tasks = [URLSessionDataTask]()

        let hueColor = HueColor.create(context: managedObjectContext, color: color)
        let newReminder = Reminder(context: managedObjectContext)
        newReminder.name = name
        newReminder.color = hueColor
        newReminder.day = day
        newReminder.time = time
        newReminder.active = true
        bridge.addToReminder(newReminder)
        
        for light in lightIDs {
            let hueLight = HueLight(context: managedObjectContext)
            hueLight.lightID = light
            newReminder.addToLight(hueLight)
            
            // TODO: Move this code to an interactor
            let request = HueAPI.setSchedule(on: newReminder.bridge!, reminder: newReminder, light: hueLight)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // TODO: Handle response and error
                let decoder = JSONDecoder.init()
                let responses = try! decoder.decode([HueSchedulesResponse].self, from: data!)
                
                if let error = responses.first?.error {
                    print("Error occurred - Type: \(error.type), Description: \(error.description), Address: \(error.address)")
                    // TODO: Show error message to user
                    return
                }
                
                if let success = responses.first?.success {
                    hueLight.scheduleID = success.id
                    
                    // Return to the list view
                    DispatchQueue.main.async {
                        try? managedObjectContext.save()
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }
            tasks.append(task)
        }
        
        // Add a push notification
        // TODO: -Idea- Create a class for creating and deleting push notifications
        let content = UNMutableNotificationContent()
        content.title = name
        content.body = lightIDs.reduce("Lights", { "\($0) \($1)" })
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                             from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let uuidString = UUID().uuidString
        let notificationRequest = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        newReminder.localNotificationId = uuidString
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(notificationRequest) { (error) in
            if error != nil {
               print("Error while setting the push notification: \(error!)")
            }
        }
        
        tasks.forEach { $0.resume() }
    }
    
    func toggleLightSelectedState(_ viewModel: NewReminderViewModel, lightID: String) {
        if viewModel.selectedLights.contains(lightID) {
            viewModel.selectedLights.remove(lightID)
        } else {
            viewModel.selectedLights.insert(lightID)
        }
    }
    
    func select(bridge: HueBridge, _ viewModel: NewReminderViewModel) {
        guard viewModel.bridge != bridge else { return }
        viewModel.selectedLights.removeAll()
        viewModel.bridge = bridge
        viewModel.fetchLights()
    }
}
