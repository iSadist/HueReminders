//
//  SharePersistentContainer.swift
//  HueReminders
//
//  Created by Jan Svensson on 2020-08-24.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import UIKit
import CoreData

class SharedPersistentContainer: NSPersistentCloudKitContainer {
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: coreDataGroupName)
        storeURL = storeURL?.appendingPathComponent("HueReminders.sqlite")
        return storeURL!
    }
}
