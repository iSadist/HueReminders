//
//  HueBridge.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-27.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import CoreData

final public class HueBridge: NSManagedObject, Findable, Comparable {
    public static func < (lhs: HueBridge, rhs: HueBridge) -> Bool {
        lhs.address! < rhs.address!
    }
    
    public static func == (lhs: HueBridge, rhs: HueBridge) -> Bool {
        lhs.name == rhs.name && lhs.address! < rhs.address!
    }
    
    public class func findAll() -> NSFetchRequest<HueBridge> {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let request: NSFetchRequest<HueBridge> = HueBridge.fetchRequest()
        request.sortDescriptors = [sortDescriptor]
        return request
    }
    
    public class func findActiveBridge() -> NSFetchRequest<HueBridge> {
        let request: NSFetchRequest<HueBridge> = HueBridge.fetchRequest()
        request.predicate = NSPredicate(format: "active == true")
        request.fetchLimit = 1
        request.fetchBatchSize = 1
        request.returnsDistinctResults = true
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }
}
