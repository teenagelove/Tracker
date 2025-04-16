//
//  TrackerStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import UIKit
import CoreData

protocol TrackerStoreProtocol {
    var managedObjectContext: NSManagedObjectContext { get }
    
}

final class TrackerStore {
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to get AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    func addNewTracker(tracker: Tracker) {
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.emoji = tracker.emoji
        trackerEntity.color = tracker.color
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                print("Failed to save emoji mix: \(error)")
            }
        }
    }
}
