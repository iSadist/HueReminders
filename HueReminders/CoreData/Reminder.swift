//
//  Reminder.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-05.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import CoreData
import NotificationCenter

final public class Reminder: NSManagedObject, Findable, Comparable {
    public static func < (lhs: Reminder, rhs: Reminder) -> Bool {
        lhs.position < rhs.position
    }
    
    public class func findAll() -> NSFetchRequest<Reminder> {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    public class func findForActiveBridge() -> NSFetchRequest<Reminder> {
        let predicate = NSPredicate(format: "bridge.active == true")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        request.returnsDistinctResults = true
        return request
    }
    
    public func removeLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        if let notificationID = localNotificationId {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [notificationID])            
        }
    }
}
