//
//  DataStoreManager.swift
//  Tracker
//
//  Created by Danil Kazakov on 16.04.2025.
//

import CoreData

enum DataStoreError: Error {
    case contextNotFound
}

final class DataStoreManager {
    static let shared = DataStoreManager()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    // MARK: - Singleton
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
