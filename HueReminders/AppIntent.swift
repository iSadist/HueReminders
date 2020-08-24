//
//  AppIntent.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-24.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import Intents

class AppIntent {
    class func requestAccess() {
        INPreferences.requestSiriAuthorization { (status) in
            let response = "Siri access "
            switch status {
            case .authorized: print(response + "Authorized")
            case .denied, .restricted: print(response + "Denied")
            case .notDetermined: print(response + "Pending")
            default: print("Unknown response from Siri Authorization request")
            }
        }
    }
    
    class func getReminders() {
        let intent = GetRemindersIntent()
        intent.suggestedInvocationPhrase = "Get the number of reminders in Hue"
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { (error) in
            if error != nil {
                print("There was an interaction error with GetRemindersIntent")
            } else {
                print("Donated GetReminders interaction successfully")
            }
        }
    }
}
