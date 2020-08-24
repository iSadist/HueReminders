//
//  IntentHandler.swift
//  DisableRemindersByVoice
//
//  Created by Jan Svensson on 2020-08-22.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Intents
import UIKit
import CoreData

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        if intent is DisableRemindersIntent {
            return DisableRemindersIntentHandler()
        }
        
        if intent is GetRemindersIntent {
            return GetRemindersIntentHandler()
        }
        
        return self
    }
}
