//
//  ReminderRowViewModel.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-11.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ReminderRowViewModel: ObservableObject {
    @Published var name: String
    @Published var color: Color
    @Published var day: String
    @Published var time: String
    @Published var lightID: String
    @Published var isActive: Bool
    
    var reminder: Reminder
    
    private var formatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        return timeFormatter
    }()
    
    init(_ reminder: Reminder) {
        name = reminder.name ?? "Unknown name"
        color = Color(ReminderColor.allCases[Int(reminder.color)].getColor())
        day = WeekDay.allCases[Int(reminder.day)].rawValue
        time = "\(formatter.string(from: reminder.time ?? Date()))"
        lightID = reminder.lightID ?? ""
        isActive = reminder.active
        self.reminder = reminder
    }
}
