//
//  TrackerStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import Foundation
import CoreData


protocol TrackerStoreProtocol {
//    var managedObjectContext: NSManagedObjectContext? { get }
    func addNewTracker(_ tracker: Tracker, categoryEntity: TrackerCategoryCoreData) throws
    func getTrackerById(by id: UUID) -> TrackerCoreData?
}

final class TrackerStore {
    private var context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStoreProtocol
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.categoryStore = TrackerCategoryStore(context: context)
    }
    
    convenience init() {
        self.init(context: DataStoreManager.shared.viewContext)
    }
}


// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
//    var managedObjectContext: NSManagedObjectContext? {
//        context
//    }
    
    func addNewTracker(_ tracker: Tracker, categoryEntity: TrackerCategoryCoreData) throws {
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.emoji = tracker.emoji
        trackerEntity.color = tracker.color
        trackerEntity.schedule = tracker.schedule as NSSet
        trackerEntity.createdAt = Date()
        trackerEntity.category = categoryEntity
        
        DataStoreManager.shared.saveContext()
    }
    
    func getTrackerById(by id: UUID) -> TrackerCoreData? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Failed to fetch tracker: \(error)")
            return nil
        }
    }
}
