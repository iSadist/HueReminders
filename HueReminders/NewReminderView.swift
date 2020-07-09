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

struct NewReminder: View {
    var onAddReminder: ((Reminder) -> Void)?

    @Environment(\.presentationMode) var presentation
    @ObservedObject private var newReminderViewModel = NewReminderViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    func addPressed() {
        // TODO: Add to a Core Data model instead
        let newReminder = Reminder(name: newReminderViewModel.name, color: newReminderViewModel.color, day: newReminderViewModel.day, time: newReminderViewModel.time)
        onAddReminder?(newReminder)
        self.presentation.wrappedValue.dismiss()
    }
    
    init(onAddReminder: ((Reminder) -> Void)?) {
        self.onAddReminder = onAddReminder
        
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
                    ForEach(0 ..< Color.allCases.count) { index in
                        Text(Color.allCases[index].rawValue)
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
