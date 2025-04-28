//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import CoreData
import UIKit

//MARK: - TrackerCategoryStoreUpdate
struct TrackerCategoryStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
}

protocol TrackerCategoryStoreProtocol {
    var categories: [String] { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func fetchCategories() -> [TrackerCategory]?
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData
    func deleteCategory(_ category: TrackerCategory) throws
    func updateCategory(oldName: String, newName: String) throws
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerCategoryStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        try? frc.performFetch()
        return frc
    }()
    
    init(context: NSManagedObjectContext = DataStoreManager.shared.viewContext, delegate: TrackerCategoryStoreDelegate? = nil) {
        self.context = context
        self.delegate = delegate
    }
}

// MARK: - Private Methods
private extension TrackerCategoryStore {
    func makeTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let color = trackerCoreData.color,
            let emoji = trackerCoreData.emoji
        else {
            return nil
        }
        
        let schedule = trackerCoreData.schedule.toWeekSet()
        
        return Tracker(
            id: id,
            name: name,
            color: color as? UIColor ?? .clear,
            emoji: emoji,
            schedule: schedule
        )
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var categories: [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results.map { $0.name ?? "" }
        } catch {
            print("Failed to fetch category names: \(error)")
            return []
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func fetchCategories() -> [TrackerCategory]? {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return fetchedObjects.map { categoryCoreData in
            let trackers = (categoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.compactMap { makeTracker(from: $0) } ?? []
            return TrackerCategory(name: categoryCoreData.name ?? "", trackers: trackers)
        }
    }
    
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", category.name)
        request.fetchLimit = 1
        
        let results = try context.fetch(request)
        
        if let existing = results.first {
            return existing
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = category.name
            newCategory.createdAt = Date()
            DataStoreManager.shared.saveContext()
            return newCategory
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", category.name)
        
        let categories = try context.fetch(fetchRequest)
        guard let categoryToDelete = categories.first else { return }
        context.delete(categoryToDelete)
        DataStoreManager.shared.saveContext()
    }
    
    func updateCategory(oldName: String, newName: String) throws {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", oldName)
        
        let results = try context.fetch(fetchRequest)
        guard let categoryToUpdate = results.first else { return }
        categoryToUpdate.name = newName
        categoryToUpdate.createdAt = Date()
        DataStoreManager.shared.saveContext()
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard
            let insertedIndexes = insertedIndexes,
            let deletedIndexes = deletedIndexes,
            let updatedIndexes = updatedIndexes else { return }
        delegate?.didUpdate(
            .init(
                insertedIndexes: insertedIndexes,
                deletedIndexes: deletedIndexes,
                updatedIndexes: updatedIndexes))
        self.insertedIndexes = nil
        self.deletedIndexes = nil
        self.updatedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            switch type {
            case .delete:
                if let indexPath = indexPath {
                    deletedIndexes?.insert(indexPath.row)
                }
            case .insert:
                if let newIndexPath = newIndexPath {
                    insertedIndexes?.insert(newIndexPath.row)
                }
            case .update:
                if let indexPath = indexPath {
                    updatedIndexes?.insert(indexPath.row)
                }
            default:
                break
            }
        }
}

