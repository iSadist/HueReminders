//
//  InspectReminder.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-09.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct InspectReminderView: View {
    @Environment(\.presentationMode) var presentation
    
    var reminder: Reminder
    
    private var cancellables = Set<AnyCancellable>()
    
    init(_ reminder: Reminder) {
        self.reminder = reminder
    }
    
    var body: some View {
        Form {
            Section {
                Text("Color").bold()
                Text(ReminderColor.allCases[reminder.color].rawValue)
            }
            Section {
                Text("Day").bold()
                Text(WeekDay.allCases[reminder.day].rawValue)
            }
            Section {
                Text("Time").bold()
                Text(reminder.time.description)
            }
        }.navigationBarTitle(reminder.name)
    }
}

