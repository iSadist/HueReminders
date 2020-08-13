//
//  Reminder.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-05.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import CoreData

final class Reminder: NSManagedObject, Identifiable, Findable, Comparable {
    static func < (lhs: Reminder, rhs: Reminder) -> Bool {
        lhs.name! < rhs.name!
    }
    
    class func findAll() -> NSFetchRequest<Reminder> {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    class func findForActiveBridge() -> NSFetchRequest<Reminder> {
        let predicate = NSPredicate(format: "bridge.active == true")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        request.returnsDistinctResults = true
        return request
    }
}
