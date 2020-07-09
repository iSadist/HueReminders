//
//  Reminder.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-08.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import SwiftUI

enum WeekDay: String, CaseIterable {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}

enum Color: String, CaseIterable {
    case White, Blue, Red, Green, Yellow, Pink, Purple, Orange
}

struct Reminder: Identifiable {
    var id = UUID()
    var name: String
    var color: Int
    var day: Int
    var time: Date
}

struct ReminderRow: View {
    var reminder: Reminder
    
    var formatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        return timeFormatter
    }()
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(reminder.name)
            Text(Color.allCases[reminder.color].rawValue)
            Text(WeekDay.allCases[reminder.day].rawValue)
            Text("\(formatter.string(from: reminder.time))")
        }
    }
}
