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

        for model in models {
            let calendar = model.calendar
            let predicate = store.predicateForEvents(withStart: Date(), end: model.endDate, calendars: [calendar])
            let events = store.events(matching: predicate)
            
            for event in events {
                // For every event, create a Reminder
                if let bridge = model.lights.first?.bridge {
                    addReminder.add(managedObjectContext: context,
                                    name: event.title,
                                    color: model.color,
                                    day: 1,
                                    time: event.startDate,
                                    bridge: bridge,
                                    lightIDs: Set(model.lights.compactMap { $0.lightID })) { (success) in
                        print(success)
                                        // TODO: Handle Success or failure
                    }
                }
            }
        }
    }
}
