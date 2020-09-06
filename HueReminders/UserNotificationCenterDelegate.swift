//
//  UserNotificationCenterDelegate.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-12.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import UserNotifications

class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = notification.request
        let content = request.content
        
//      Delete the reminder

//        if let reminder = content.userInfo["reminder"] as? Reminder {
//            context.delete(reminder)
//            try? context.save()
//        }
        
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // TODO: Display the reminder details
        print("Just opened from a notification")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("open settings for")
    }
}
