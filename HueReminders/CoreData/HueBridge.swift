//
//  HueBridge.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-27.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import CoreData

public class HueBridge: NSManagedObject, Identifiable {
    class func findAll() -> NSFetchRequest<HueBridge> {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let request: NSFetchRequest<HueBridge> = HueBridge.fetchRequest()
        request.sortDescriptors = [sortDescriptor]
        return request
    }
}
