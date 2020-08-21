//
//  SyncViewModel.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-20.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Combine
import EventKit
import UIKit

class CalendarRowModel: ObservableObject, Identifiable {
    var id = UUID()
    @Published var title: String
    @Published var color: UIColor
    @Published var selected: Bool = false
    
    init(calendar: EKCalendar) {
        title = calendar.title
        color = UIColor(cgColor: calendar.cgColor)
    }
}

class SyncViewModel: ObservableObject {
    @Published var calendars: [CalendarRowModel] = []

    var store: EKEventStore // TODO: Perhaps create an Event Store class to perform some of these things? Could maybe be a singleton class?

    init() {
        store = EKEventStore()
        self.setupCalendar()
    }
    
    func setupCalendar() { // TODO: Also move this out of the View model
        store.requestAccess(to: .event) { (granted, error) in
            print("Calendar access granted: \(granted)")
            
            if error != nil {
                print(error)
            }
            
            let calendars = self.store.calendars(for: .event)
            
            for calendar in calendars {
                let row = CalendarRowModel(calendar: calendar)
                self.calendars.append(row)
            }
        }
    }
    
    func populateCalendar() {
        let calendars = store.calendars(for: .event)
        
        for calendar in calendars {
            let row = CalendarRowModel(calendar: calendar)
            self.calendars.append(row)
        }
    }
}
