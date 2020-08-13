//
//  UserNotificationCenterDelegate.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-12.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import UserNotifications

class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //
        print("Just triggered a notification")
        completionHandler()
    }
}
