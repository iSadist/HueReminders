//
//  SyncInteractor.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-28.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import EventKit
import SwiftUI

protocol SyncInteracting {
    func sync(_ models: [CalendarSyncModel])
}

final class SyncInteractor: SyncInteracting {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let addReminder = AddReminderInteractor()
    
    func sync(_ models: [CalendarSyncModel]) {
        let store = EKEventStore()

        // Go throught all calendars
        for model in models {
            let calendar = model.calendar

            let predicate = store.predicateForEvents(withStart: Date(), end: model.endDate, calendars: [calendar])
            // Get all events up until a specific date
            let events = store.events(matching: predicate)
            
            for event in events {
                // For every event, create a Reminder

                // Must also create a reminder for every light
                
                let color = model.color
                if let bridge = model.lights.first?.bridge {
                    
                    print("Event \(event.title), Bridge: \(bridge.name), lights: \(Set(model.lights.compactMap { $0.lightID }))")
                    addReminder.add(managedObjectContext: context,
                                    name: event.title,
                                    color: 1,
                                    day: 1,
                                    time: event.startDate,
                                    bridge: bridge,
                                    lightIDs: Set(model.lights.compactMap { $0.lightID })) { (success) in
                        print(success)
                    }
                }
            }
        }
    }
}
