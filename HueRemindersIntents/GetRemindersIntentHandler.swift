//
//  GetRemindersIntentHandler.swift
//  HueRemindersIntents
//
//  Created by Jan Svensson on 2020-08-24.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

class GetRemindersIntentHandler: NSObject, GetRemindersIntentHandling {
    func handle(intent: GetRemindersIntent, completion: @escaping (GetRemindersIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: NSStringFromClass(GetRemindersIntent.self))
        let context = persistentContainer.viewContext
        let request = Reminder.findAll()
        
        guard let results = try? context.fetch(request) else {
            completion(.init(code: .failure, userActivity: userActivity)); return
        }
        
        completion(.success(amount: NSNumber(value: results.count)))
    }
}
