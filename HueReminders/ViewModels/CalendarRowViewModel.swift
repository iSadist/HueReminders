//
//  CalendarRowViewModel.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-27.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Combine
import UIKit
import EventKit

class CalendarRowModel: ObservableObject, Identifiable {
    var id = UUID()
    @Published var title: String
    @Published var color: UIColor
    @Published var selected: Bool = false
    @Published var lights: Set<HueLight> = []
    
    init(calendar: EKCalendar) {
        title = calendar.title
        color = UIColor(cgColor: calendar.cgColor)
    }
    
    var isSelected: AnyPublisher<Bool, Never> {
        $selected
            .map { $0 }
            .eraseToAnyPublisher()
    }
}
