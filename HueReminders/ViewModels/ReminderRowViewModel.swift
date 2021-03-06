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
    @Published var isActive: Bool
    
    var reminder: Reminder
    var bridge: HueBridge
    
    private var formatter: DateFormatter = {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        return timeFormatter
    }()
    
    init(_ reminder: Reminder, _ bridge: HueBridge) {
        name = reminder.name ?? "Unknown name"
        guard let c = reminder.color else { fatalError("missing color") }
        let uiColor = UIColor(hue: CGFloat(c.hue),
                         saturation: CGFloat(c.saturation),
                         brightness: CGFloat(c.brightness),
                         alpha: CGFloat(c.alpha))
        color = Color(uiColor)
        day = WeekDay.allCases[Int(reminder.day)].rawValue
        time = "\(formatter.string(from: reminder.time ?? Date()))"
        isActive = reminder.active
        self.reminder = reminder
        self.bridge = bridge
    }
}
