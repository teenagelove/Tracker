//
//  TrackerDataProvider.swift
//  Tracker
//
//  Created by Danil Kazakov on 16.04.2025.
//

import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol TrackerDataProviderDelegate: AnyObject {
    func didUpdateTrackers(_ update: TrackerStoreUpdate)
}

protocol TrackerDataProviderProtocol {
    var numberOfSections: Int { get }
    var trackers: [Tracker] { get }
    var categoriesCount: Int { get }
    func updateFilter(currentDate: Date, searchText: String?)
    func numbersOfRowsInSections(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func trackerCoreData(by id: UUID) -> TrackerCoreData?
    func addNewTracker(tracker: Tracker, category: TrackerCategory) throws
    func nameOfSection(_ section: Int) -> String
}

final class TrackerDataProvider: NSObject {
    weak var delegate: TrackerDataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let dataStore: TrackerStoreProtocol
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var insertedSections: IndexSet = []
    private var deletedSections: IndexSet = []
    private let categoryProvider: TrackerCategoryProviderProtocol
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.name",
            cacheName: nil
        )
        
        controller.delegate = self
        
        try? controller.performFetch()
        
        return controller
    }()
    
    init(_ store: TrackerStoreProtocol, delegate: TrackerDataProviderDelegate) throws {
        self.context = DataStoreManager.shared.viewContext
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
        fetchedResultsController.sections?.count ?? 0
    }
    
    var trackers: [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else { return [] }
        return objects.map(modelFrom(object:))
    }
    
    var categoriesCount: Int {
        categoryProvider.categories.count
    }
    
    func updateFilter(currentDate: Date, searchText: String?) {
        var predicates: [NSPredicate] = []

        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }

        let weekday = Calendar.current.component(.weekday, from: currentDate)
        let weekdayStr = "\(weekday)"

        let schedulePredicate = NSPredicate(format: "schedule CONTAINS[c] %@ OR schedule == nil", weekdayStr)

        predicates.append(schedulePredicate)

        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            try fetchedResultsController.performFetch()
            let update = TrackerStoreUpdate(
                insertedIndexPaths: insertedIndexPaths,
                deletedIndexPaths: deletedIndexPaths,
                insertedSections: insertedSections,
                deletedSections: deletedSections
            )
            delegate?.didUpdateTrackers(update)
        } catch {
            print("Failed to perform fetch with updated predicate: \(error)")
        }
    }
    
    func numbersOfRowsInSections(in section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let object = fetchedResultsController.object(at: indexPath)
        return modelFrom(object: object)
    }
    
    func trackerCoreData(by id: UUID) -> TrackerCoreData? {
        fetchedResultsController.fetchedObjects?.first { $0.id == id }
    }
    
    func addNewTracker(tracker: Tracker, category: TrackerCategory) throws {
        let categoryEntity = try categoryProvider.fetchOrCreateCategory(from: category)
        try dataStore.addNewTracker(tracker, categoryEntity: categoryEntity)
    }
    
    func nameOfSection(_ section: Int) -> String {
        fetchedResultsController.sections?[section].name ?? ""
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension TrackerDataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexPaths = []
        deletedIndexPaths = []
        insertedSections = []
        deletedSections = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        let update = TrackerStoreUpdate(
            insertedIndexPaths: insertedIndexPaths,
            deletedIndexPaths: deletedIndexPaths,
            insertedSections: insertedSections,
            deletedSections: deletedSections
        )
        delegate?.didUpdateTrackers(update)
        insertedIndexPaths = []
        deletedIndexPaths = []
        insertedSections = []
        deletedSections = []
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSections.insert(sectionIndex)
        case .delete:
            deletedSections.insert(sectionIndex)
        default:
            break
        }
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
                insertedIndexPaths.append(newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                deletedIndexPaths.append(indexPath)
                insertedIndexPaths.append(newIndexPath)
            }
        default:
            break
        }
    }
}
