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

protocol AddReminderInteracting {
    func add(managedObjectContext: NSManagedObjectContext,
             name: String,
             color: Int16,
             day: Int16,
             time: Date,
             bridge: HueBridge,
             lightIDs: Set<String>,
             completion: @escaping (Bool) -> Void)
}

final class AddReminderInteractor: AddReminderInteracting {
    func add(managedObjectContext: NSManagedObjectContext,
             name: String,
             color: Int16,
             day: Int16,
             time: Date,
             bridge: HueBridge,
             lightIDs: Set<String>,
             completion: @escaping (Bool) -> Void) {
        var tasks = [URLSessionDataTask]()
        
        let newReminder = Reminder(context: managedObjectContext)
        newReminder.name = name
        newReminder.color = color
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
        let content = UNMutableNotificationContent()
        content.title = name
        content.body = "Triggered by HueReminders"
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                             from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let uuidString = UUID().uuidString // Save this to be able to cancel the
        let notificationRequest = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(notificationRequest) { (error) in
            if error != nil {
               print("Error while setting the push notification: \(error!)")
            }
        }
        
        tasks.forEach { $0.resume() }
    }
}
