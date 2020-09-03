//
//  CreateReminderIntentHandler.swift
//  HueRemindersIntents
//
//  Created by Jan Svensson on 2020-08-25.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Intents
import UIKit

class CreateReminderIntentHandler: NSObject, CreateReminderIntentHandling {
    private var interactor: AddReminderInteracting = AddReminderInteractor()
    
    func handle(intent: CreateReminderIntent, completion: @escaping (CreateReminderIntentResponse) -> Void) {
        let userActivity = NSUserActivity(activityType: NSStringFromClass(CreateReminderIntent.self))
        guard let name = intent.name else {
            completion(.init(code: .failure, userActivity: userActivity)); return
        }
        guard let time = intent.time, let date = time.date else {
            completion(.init(code: .failure, userActivity: userActivity)); return
        }
        let color = ReminderColor.allCases[intent.color.rawValue].getColor()
        let context = persistentContainer.viewContext
        let bridgeRequest = HueBridge.findActiveBridge()
        let bridgeResult = try? context.fetch(bridgeRequest)
        guard let bridge = bridgeResult?.first else {
            completion(.init(code: .failure, userActivity: userActivity)); return
        }
        
        // Create the reminder
        interactor.add(managedObjectContext: context,
                       name: name,
                       color: color,
                       day: 0,
                       time: date,
                       bridge: bridge,
                       lightIDs: ["1"]) { success in
            if success {
                completion(.success(name: intent.name ?? "Reminder", time: intent.time!))
            } else {
                completion(.init(code: .failure, userActivity: userActivity)); return
            }
        }
    }
    
    func resolveName(for intent: CreateReminderIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        var result: INStringResolutionResult
        
        if let name = intent.name, name.count != 0 {
            result = INStringResolutionResult.success(with: name)
        } else {
            result = INStringResolutionResult.needsValue()
        }

        completion(result)
    }
    
    func resolveTime(for intent: CreateReminderIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        if let time = intent.time {
            completion(INDateComponentsResolutionResult.success(with: time))
        } else {
            completion(INDateComponentsResolutionResult.needsValue())
        }
    }
    
    func resolveColor(for intent: CreateReminderIntent, with completion: @escaping (IntentColorResolutionResult) -> Void) {
        completion(IntentColorResolutionResult.success(with: intent.color))
    }
}
