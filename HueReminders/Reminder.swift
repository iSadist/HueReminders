//
//  Reminder.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

struct Reminder: Identifiable {
    var id = UUID()
    var name: String
    var color: String
    var day: String
    var time: String
}

struct ReminderRow: View {
    var reminder: Reminder
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(reminder.name)
            Text(reminder.color)
            Text(reminder.day)
            Text(reminder.time)
        }
    }
}
