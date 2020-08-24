//
//  Enums.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-24.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import UIKit

enum WeekDay: String, CaseIterable {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday // swiftlint:disable identifier_name
}

enum ReminderColor: String, CaseIterable {
    case White, Blue, Red, Green, Yellow, Pink, Purple, Orange // swiftlint:disable identifier_name
    
    func getColor() -> UIColor {
        switch self {
        case .White: return .white
        case .Blue: return .blue
        case .Red: return .red
        case .Green: return .green
        case .Yellow: return .yellow
        case .Pink: return .systemPink
        case .Purple: return .purple
        case .Orange: return .orange
        }
    }
}
