//
//  PersistentContainer.swift
//  HueRemindersIntents
//
//  Created by Jan Svensson on 2020-08-24.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation
import CoreData

var persistentContainer: SharedPersistentContainer = {
    let container = SharedPersistentContainer(name: containerName)
    
    guard let description = container.persistentStoreDescriptions.first else {
        fatalError("No description found")
    }
    description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        print(storeDescription)
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    return container
}()
