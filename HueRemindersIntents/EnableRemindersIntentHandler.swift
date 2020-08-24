//
//  EnableRemindersIntentHandler.swift
//  HueRemindersIntents
//
//  Created by Jan Svensson on 2020-08-24.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Intents
import UIKit
import CoreData

class EnableRemindersIntentHandler: NSObject, EnableRemindersIntentHandling {
    func handle(intent: EnableRemindersIntent, completion: @escaping (EnableRemindersIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: NSStringFromClass(DisableRemindersIntent.self))
        let context = persistentContainer.viewContext
        let request = Reminder.findAll()
        
        guard let results = try? context.fetch(request) else {
            completion(.init(code: .failure, userActivity: userActivity)); return
        }
        
        var changed = 0
        
        for reminder in results {
            // TODO: Also make the proper request to update Hue Bridge
            if !reminder.active {
                changed += 1
                reminder.active = true                
            }
        }
        
        do {
            if context.hasChanges {
                try context.save()
            }
            completion(.success(amount: NSNumber(value: changed)))
        } catch {
            print(error)
            completion(.init(code: .failure, userActivity: userActivity))
        }
    }
}
