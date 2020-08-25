//
//  NSUserActivity+Extensions.swift
//  HueRemindersIntents
//
//  Created by Jan Svensson on 2020-08-25.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Intents

extension NSUserActivity {
    
    public static let getRemindersActivityType = "com.jansvenssoncv.HueReminders.getReminders"
    
    public static var getRemindersActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: NSUserActivity.getRemindersActivityType)
        
        userActivity.title = "Show me all lights"
        userActivity.persistentIdentifier = NSUserActivityPersistentIdentifier(NSUserActivity.getRemindersActivityType)
        userActivity.isEligibleForSearch = true
        userActivity.suggestedInvocationPhrase = "Show me all lights"
        
        return userActivity
    }
}
