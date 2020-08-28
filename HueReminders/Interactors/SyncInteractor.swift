//
//  SyncInteractor.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-28.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

protocol SyncInteracting {
    func sync(_ models: [CalendarSyncModel])
}

final class SyncInteractor: SyncInteracting {
    func sync(_ models: [CalendarSyncModel]) {
        print("Start syncing...")
        
        print(models.count)
        
        for model in models {
            print(model.calendar)
            print(model.lights.count)
        }
        
        // Go throught all calendars
        
        // Get all events up until a specific date
        
        // For every event, create a Reminder
    }
}
