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
                Text(ReminderColor.allCases[Int(reminder.color)].rawValue)
            }
            Section {
                Text("Day").bold()
                Text(WeekDay.allCases[Int(reminder.day)].rawValue)
            }
            Section {
                Text("Time").bold()
                Text(reminder.time!.description)
            }
        }.navigationBarTitle(reminder.name!)
    }
}

struct InspectReminder_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let reminder = Reminder(context: context)
        reminder.active = true
        reminder.color = 1
        reminder.day = 1
        reminder.name = "Reminder"
        reminder.time = Date()

        return InspectReminderView(reminder)
    }
}
