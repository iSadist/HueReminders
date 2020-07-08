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
    
    func addPressed() {
        // TODO: Add to a Core Data model instead
        let newReminder = Reminder(name: newReminderViewModel.name, color: newReminderViewModel.color, day: newReminderViewModel.day, time: newReminderViewModel.time)
        onAddReminder?(newReminder)
        self.presentation.wrappedValue.dismiss()
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $newReminderViewModel.name)
                    .autocapitalization(.none)
            }
            Section {
                TextField("Color", text: $newReminderViewModel.color)
            }
            Section {
                TextField("Day", text: $newReminderViewModel.day)
            }
            Section {
                TextField("Time", text: $newReminderViewModel.time)
            }
            Section {
                Button(action: addPressed) {
                    Text("Add").bold()
                }.disabled(!newReminderViewModel.isValid)
            }
        }.navigationBarTitle("New reminder")
    }
}
