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
    func sync(_ models: [CalendarSyncModel], completion: @escaping ((Float) -> Void))
}

final class SyncInteractor: SyncInteracting {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let addReminder = AddReminderInteractor()
    
    func sync(_ models: [CalendarSyncModel], completion: @escaping ((Float) -> Void)) {
        let store = EKEventStore()
        var totalEvents = 0
        var processed = 0

        for (modelIndex, model) in models.enumerated() {
            let calendar = model.calendar
            let predicate = store.predicateForEvents(withStart: Date(), end: model.endDate, calendars: [calendar])
            let events = store.events(matching: predicate)
            
            totalEvents += events.count
            
            for (eventIndex, event) in events.enumerated() {
                // For every event, create a Reminder
                if let bridge = model.lights.first?.bridge {
                    addReminder.add(managedObjectContext: context,
                                    name: event.title,
                                    color: model.color,
                                    day: 1,
                                    time: event.startDate,
                                    bridge: bridge,
                                    lightIDs: Set(model.lights.compactMap { $0.lightID })) { (success) in
                                        // TODO: Handle Success or failure
                                        if success {
                                            processed += 1
                                        }
                                        
                                        completion(Float(processed) / Float(totalEvents))

                                        if models.count-1 == modelIndex && events.count-1 == eventIndex {
                                            completion(1.0)
                                        }
                    }
                }
            }
        }
    }
}
