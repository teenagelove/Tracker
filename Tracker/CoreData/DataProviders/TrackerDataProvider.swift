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
    private let categoryProvider: TrackerCategoryDataProviderProtocol
    
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
    
    init(_ store: TrackerStoreProtocol, categoryProvider: TrackerCategoryDataProviderProtocol, delegate: TrackerDataProviderDelegate) throws {
        self.context = DataStoreManager.shared.viewContext
        self.delegate = delegate
        dataStore = store
        self.categoryProvider = categoryProvider
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
            schedule: object.schedule.toWeekSet()
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
    
    func updateFilter(currentDate: Date, searchText: String?) {
        var predicates: [NSPredicate] = []

        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }

        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let weekdayStr = "\(weekday)"
        
        let startOfDay = calendar.startOfDay(for: currentDate)
        let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Предикат отображает трекеры по дням недели из их расписания.
        // И если у трекера schedule == nil (нерегулярное событие), тогда:
        // 1. Он не выполнен ни разу - отображаем каждый день
        // 2. Но если был выполнен хотя бы раз - отображаем только в день выполнения.
        let eventDisplayPredicate = NSPredicate(
            format: """
            (schedule != nil AND schedule CONTAINS[c] %@) OR
            (schedule == nil AND (
                SUBQUERY(records, $r, $r.tracker == SELF).@count == 0 OR
                SUBQUERY(records, $r, $r.date >= %@ AND $r.date < %@).@count > 0
            ))
            """,
            weekdayStr,
            startOfDay as NSDate,
            startOfNextDay as NSDate
        )
        
        predicates.append(eventDisplayPredicate)

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
        default:
            break
        }
    }
}
