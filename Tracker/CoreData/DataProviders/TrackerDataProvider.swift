//
//  TrackerDataProvider.swift
//  Tracker
//
//  Created by Danil Kazakov on 16.04.2025.
//

import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdateTrackers(_ update: TrackerStoreUpdate)
}

protocol TrackerDataProviderProtocol {
    var numberOfSections: Int { get }
    func setupFetchedResultsController(filterDate: Date?, searchText: String?)
    func numbersOfRowsInSections(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func addNewTracker(tracker: Tracker, category: TrackerCategory) throws
}

final class TrackerDataProvider: NSObject {
    weak var delegate: TrackerDataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: TrackerStoreProtocol
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    private let categoryProvider: TrackerCategoryProviderProtocol
    
    init(_ store: TrackerStoreProtocol, delegate: TrackerDataProviderDelegate) throws {
        guard let context = store.managedObjectContext else {
            throw DataStoreError.contextNotFound
        }
        self.context = context
        self.delegate = delegate
        dataStore = store
        categoryProvider = TrackerCategoryProvider()
    }
}

// MARK: - Private Methods
private extension TrackerDataProvider {
    func modelFrom(object: TrackerCoreData) -> Tracker {
        Tracker(
            id: object.id ?? UUID(),
            name: object.name ?? "",
            color: object.color as? UIColor ?? UIColor.clear,
            emoji: object.emoji ?? "🍻",
            schedule: object.schedule as? Set<Week> ?? []
        )
    }
}

// MARK: - TrackerDataProviderProtocol
extension TrackerDataProvider: TrackerDataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    func setupFetchedResultsController(filterDate: Date?, searchText: String?) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        var predicates: [NSPredicate] = []

        if let search = searchText, !search.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", search))
        }

        if let date = filterDate {
            let weekday = Calendar.current.component(.weekday, from: date)
            let datePredicate = NSPredicate(format: "ANY schedule.weekday == %d OR schedule.@count == 0", weekday)
            predicates.append(datePredicate)
        }

        fetchRequest.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            delegate?.didUpdateTrackers(TrackerStoreUpdate(insertedIndexes: [], deletedIndexes: []))
        } catch {
            print("Failed to perform fetch: \(error)")
        }
    }
    
    func numbersOfRowsInSections(in section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard let object = fetchedResultsController?.object(at: indexPath) else { return nil }
        return modelFrom(object: object)
    }
    
    func addNewTracker(tracker: Tracker, category: TrackerCategory) throws {
        //        try dataStore.addNewTracker(tracker, category: category)
        let categoryEntity = try categoryProvider.fetchOrCreateCategory(from: category)
        try dataStore.addNewTracker(tracker, categoryEntity: categoryEntity)
        setupFetchedResultsController(filterDate: nil, searchText: nil)
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard let insertedIndexes = insertedIndexes, let deletedIndexes = deletedIndexes else { return }
        delegate?.didUpdateTrackers(TrackerStoreUpdate(insertedIndexes: insertedIndexes, deletedIndexes: deletedIndexes))
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes?.insert(newIndexPath.row)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.row)
            }
        default:
            break
        }
    }
}
