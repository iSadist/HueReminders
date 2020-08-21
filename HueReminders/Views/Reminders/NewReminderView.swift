//
//  NewReminderView.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct NewReminderView: View {
    @FetchRequest(fetchRequest: HueBridge.findAll()) var bridges: FetchedResults<HueBridge>
    
    private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        // BUG: Does not update to the active bridge
        NewReminderViewContent(bridges: bridges.sorted())
    }
}

struct NewReminderViewContent: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var viewModel: NewReminderViewModel

    var bridges: [HueBridge]
    
    private var cancellables = Set<AnyCancellable>()
    
    init(bridges: [HueBridge]) {
        self.bridges = bridges
        viewModel = NewReminderViewModel()
        
        // Setup subscriber
        viewModel.isNameValid
            .combineLatest(viewModel.selectedLightPublisher)
            .map { $0.0 && $0.1 }
            .receive(on: RunLoop.main)
            .assign(to: \.valid, on: viewModel)
            .store(in: &cancellables)
    }
    
    func addPressed() {
        // Create a wrapper function for doing this. Make it conform to a protocol
        var tasks = [URLSessionDataTask]()
        
        let newReminder = Reminder(context: managedObjectContext)
        newReminder.name = viewModel.name
        newReminder.color = Int16(viewModel.color)
        newReminder.day = Int16(viewModel.day)
        newReminder.time = viewModel.time
        newReminder.active = true
        viewModel.bridge?.addToReminder(newReminder)
        
        for light in viewModel.selectedLights {
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
                        try? self.managedObjectContext.save()
                        self.presentation.wrappedValue.dismiss() // Only return when the last one is saved
                    }
                }
            }
            tasks.append(task)
        }
        
        // Add a push notification
        let content = UNMutableNotificationContent()
        content.title = viewModel.name
        content.body = "Triggered by HueReminders"
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                             from: viewModel.time)
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
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $viewModel.name)
                    .autocapitalization(.none)
            }
            Section {
                // Swap for the color picker in iOS 14. Currently in beta
                Picker("Color", selection: $viewModel.color) {
                    ForEach(0 ..< ReminderColor.allCases.count) { index in
                        Text(ReminderColor.allCases[index].rawValue)
                    }
                }
            }
            Section {
                Picker("Day", selection: $viewModel.day) {
                    ForEach(0 ..< WeekDay.allCases.count) { index in
                        Text(WeekDay.allCases[index].rawValue)
                    }
                }
            }
            Section {
                DatePicker("Time", selection: $viewModel.time, displayedComponents: .hourAndMinute)
            }
            
            Section {
                Text("Hue Bridge")
                    .bold()
                
                if bridges.isEmpty {
                    EmptyView(text: "No connected bridge found. Go to setup to connect.")
                }
                
                ForEach(bridges) { bridge in
                    HStack {
                        Text("\(bridge.name ?? "")")
                        Spacer()
                        
                        if bridge.name == self.viewModel.bridge?.name {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .onTapGesture {
                        guard self.viewModel.bridge != bridge else { return }
                        self.viewModel.selectedLights.removeAll()
                        self.viewModel.bridge = bridge
                        self.viewModel.fetchLights()
                    }
                }
            }
            
            if self.viewModel.bridge != nil {
                Section {
                    Text("Light to blink").bold()
                    
                    if self.viewModel.lights.isEmpty {
                        EmptyView(text: "No lights found for the selected bridge")
                    }

                    ForEach(self.viewModel.lights) { light in
                        HStack {
                            Text("\(light.name)")
                                .onTapGesture {
                                    if self.viewModel.selectedLights.contains(light.id) {
                                        self.viewModel.selectedLights.remove(light.id)
                                    } else {
                                        self.viewModel.selectedLights.insert(light.id)
                                    }
                            }
                            Spacer()
                            
                            if self.viewModel.selectedLights.contains(light.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
            
            Section {
                Button(action: addPressed) {
                    Text("Add").bold()
                }.disabled(!viewModel.valid)
            }
        }.navigationBarTitle("New reminder")
    }
}

struct NewReminderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let bridge = HueBridge(context: context)
        bridge.active = true
        bridge.address = "192.168.1.2"
        bridge.name = "Bridge"
        bridge.username = "fe9c003c-a646-430f-a189-516620fc5555"
        return NewReminderViewContent(bridges: [bridge])
    }
}
