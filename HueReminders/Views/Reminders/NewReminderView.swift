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
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: HueBridge.findActiveBridge()) var activeBridge: FetchedResults<HueBridge>
    @ObservedObject private var newReminderViewModel = NewReminderViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    func addPressed() {
        let newReminder = Reminder(context: managedObjectContext)
        newReminder.name = newReminderViewModel.name
        newReminder.color = Int16(newReminderViewModel.color)
        newReminder.day = Int16(newReminderViewModel.day)
        newReminder.time = newReminderViewModel.time
        newReminder.active = false
        newReminder.bridge = activeBridge.sorted().first
        
        let request = HueAPI.setSchedule(on: newReminder.bridge!, reminder: newReminder)
        URLSession.shared.dataTask(with: request).resume()
        
        try? managedObjectContext.save()
        self.presentation.wrappedValue.dismiss()
    }
    
    init() {
        // Setup subscriber
        newReminderViewModel.isNameValid
            .receive(on: RunLoop.main)
            .assign(to: \.valid, on: newReminderViewModel)
            .store(in: &cancellables)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $newReminderViewModel.name)
                    .autocapitalization(.none)
            }
            Section {
                // Swap for the color picker in iOS 14. Currently in beta
                Picker("Color", selection: $newReminderViewModel.color) {
                    ForEach(0 ..< ReminderColor.allCases.count) { index in
                        Text(ReminderColor.allCases[index].rawValue)
                    }
                }
            }
            Section {
                Picker("Day", selection: $newReminderViewModel.day) {
                    ForEach(0 ..< WeekDay.allCases.count) { index in
                        Text(WeekDay.allCases[index].rawValue)
                    }
                }
            }
            Section {
                DatePicker("Time", selection: $newReminderViewModel.time, displayedComponents: .hourAndMinute)
            }
            Section {
                Button(action: addPressed) {
                    Text("Add").bold()
                }.disabled(!newReminderViewModel.valid)
            }
        }.navigationBarTitle("New reminder")
    }
}

struct NewReminderView_Previews: PreviewProvider {
    static var previews: some View {
        NewReminderView()
    }
}
