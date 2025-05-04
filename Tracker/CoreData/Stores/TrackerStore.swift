//
//  TrackerStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexPaths: [IndexPath]
    let deletedIndexPaths: [IndexPath]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers(_ update: TrackerStoreUpdate)
}

protocol TrackerStoreProtocol {
    var numberOfSections: Int { get }
    var trackers: [Tracker] { get }
    func nameOfSection(_ section: Int) -> String
    func updateFilter(currentDate: Date, searchText: String?)
    func numbersOfRowsInSections(in section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func tracker(by id: UUID) -> TrackerCoreData?
    func addNewTracker(tracker: Tracker, category: TrackerCategory) throws
    func deleteTracker(at indexPath: IndexPath)
    func updateTracker(tracker: Tracker, category: TrackerCategory)
    func togglePin(for id: UUID)
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let categoryStore: TrackerCategoryStoreProtocol
    
    private var insertedIndexPaths: [IndexPath] = []
    private var deletedIndexPaths: [IndexPath] = []
    private var insertedSections: IndexSet = []
    private var deletedSections: IndexSet = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.createdAt", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category",
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    init(
        context: NSManagedObjectContext = DataStoreManager.shared.viewContext,
        categoryStore: TrackerCategoryStoreProtocol,
        delegate: TrackerStoreDelegate
    ) {
        self.context = context
        self.categoryStore = categoryStore
        self.delegate = delegate
    }
}

// MARK: - Private Methods
private extension TrackerStore {
    func modelFrom(_ object: TrackerCoreData) -> Tracker {
        Tracker(
            id: object.id ?? UUID(),
            name: object.name ?? "",
            color: object.color as? UIColor ?? .clear,
            emoji: object.emoji ?? "❓",
            schedule: object.schedule.toWeekSet(),
            isPinned: object.isPinned
        )
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    var trackers: [Tracker] {
        fetchedResultsController.fetchedObjects?.map { modelFrom($0) } ?? []
    }
    
    func nameOfSection(_ section: Int) -> String {
        guard let sectionInfo = fetchedResultsController.sections?[section],
              let firstObject = sectionInfo.objects?.first as? TrackerCoreData,
              let category = firstObject.category else {
            return ""
        }
        return category.name ?? ""
    }
    
    func numbersOfRowsInSections(in section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        modelFrom(fetchedResultsController.object(at: indexPath))
    }
    
    func tracker(by id: UUID) -> TrackerCoreData? {
        fetchedResultsController.fetchedObjects?.first { $0.id == id }
    }
    
    
    func updateFilter(currentDate: Date, searchText: String?) {
        var predicates: [NSPredicate] = []
        
        if let searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchText))
        }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let weekdayStr = "\(weekday)"
        let startOfDay = calendar.startOfDay(for: currentDate)
        
        // Предикат отображает трекеры по дням недели из их расписания.
        // И если у трекера schedule == nil (нерегулярное событие), тогда:
        // 1. Он не выполнен ни разу - отображаем каждый день
        // 2. Если был выполнен хотя бы раз - отображаем только в день выполнения.
        let predicate = NSPredicate(
            format: """
            (schedule != nil AND schedule CONTAINS[c] %@) OR
            (schedule == nil AND (
                SUBQUERY(records, $r, $r.tracker == SELF).@count == 0 OR
                SUBQUERY(records, $r, $r.date == %@).@count > 0
            ))
            """,
            weekdayStr, startOfDay as NSDate
        )
        
        predicates.append(predicate)
        
        fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            try fetchedResultsController.performFetch()
            let update = TrackerStoreUpdate(
                insertedIndexPaths: [],
                deletedIndexPaths: [],
                insertedSections: [],
                deletedSections: []
            )
            delegate?.didUpdateTrackers(update)
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    func addNewTracker(tracker: Tracker, category: TrackerCategory) throws {
        let categoryEntity = try categoryStore.fetchOrCreateCategory(from: category)
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.emoji = tracker.emoji
        trackerEntity.color = tracker.color
        trackerEntity.schedule = tracker.schedule.toCoreDataString()
        trackerEntity.createdAt = Date()
        trackerEntity.category = categoryEntity
        DataStoreManager.shared.saveContext()
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        let tracker = fetchedResultsController.object(at: indexPath)
        context.delete(tracker)
        DataStoreManager.shared.saveContext()
    }
    
    func updateTracker(tracker: Tracker, category: TrackerCategory) {
        guard let existingTracker = self.tracker(by: tracker.id) else {
            print("Tracker with id \(tracker.id) not found for update.")
            return
        }

        do {
            let categoryEntity = try categoryStore.fetchOrCreateCategory(from: category)
            
            existingTracker.name = tracker.name
            existingTracker.color = tracker.color
            existingTracker.emoji = tracker.emoji
            existingTracker.schedule = tracker.schedule.toCoreDataString()
            
            if existingTracker.isPinned {
                existingTracker.originalCategory = categoryEntity.name
            } else {
                existingTracker.category = categoryEntity
            }
            
            DataStoreManager.shared.saveContext()
        } catch {
            print("Failed to fetch or create category for tracker update: \(error)")
        }
    }
    
    func togglePin(for id: UUID) {
        guard let tracker = fetchedResultsController.fetchedObjects?.first(where: { $0.id == id }) else { return }
        tracker.isPinned.toggle()
        
        let pinnedCategoryName = Constants.UIString.pinned
        let pinnedCategory = TrackerCategory(name: pinnedCategoryName, trackers: [])
        
        if tracker.isPinned {
            if tracker.originalCategory == nil {
                tracker.originalCategory = tracker.category?.name
            }
            tracker.category = try? categoryStore.fetchOrCreateCategory(from: pinnedCategory)
        } else {
            let originalCategory = TrackerCategory(
                name: tracker.originalCategory ?? "",
                trackers: []
            )
            tracker.category = try? categoryStore.fetchOrCreateCategory(from: originalCategory)
            tracker.originalCategory = nil
        }
        
        DataStoreManager.shared.saveContext()
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndexPaths = []
        deletedIndexPaths = []
        insertedSections = []
        deletedSections = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateTrackers(TrackerStoreUpdate(
            insertedIndexPaths: insertedIndexPaths,
            deletedIndexPaths: deletedIndexPaths,
            insertedSections: insertedSections,
            deletedSections: deletedSections
        ))
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
            if let newIndexPath { insertedIndexPaths.append(newIndexPath) }
        case .delete:
            if let indexPath { deletedIndexPaths.append(indexPath) }
        case .move:
            if let indexPath = indexPath {
                deletedIndexPaths.append(indexPath)
            }
            if let newIndexPath = newIndexPath {
                insertedIndexPaths.append(newIndexPath)
            }
        default:
            break
        }
    }
}
