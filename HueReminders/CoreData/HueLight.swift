//
//  HueLight.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-07-27.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import CoreData

final public class HueLight: NSManagedObject, Identifiable, Findable {
    public class func findAll() -> NSFetchRequest<HueLight> {
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let request: NSFetchRequest<HueLight> = HueLight.fetchRequest()
        request.sortDescriptors = [sortDescriptor]
        return request
    }
}
