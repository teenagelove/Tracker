//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import CoreData

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidTrackerID
    case decodingErrorInvalidDate
}

protocol TrackerRecordStoreProtocol {
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func removeTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func isTrackerCompletedToday(id: UUID, date: Date) -> Bool
    func completedTrackersCount(for trackerId: UUID) -> Int
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStoreProtocol

    init(
        context: NSManagedObjectContext = DataStoreManager.shared.viewContext,
        trackerStore: TrackerStoreProtocol
    ) {
        self.context = context
        self.trackerStore = trackerStore
    }
}

// MARK: - Private Methods
private extension TrackerRecordStore {
    func fetchTrackerRecords(for trackerId: UUID, on date: Date) throws -> [TrackerRecordCoreData] {
        let date = Calendar.current.startOfDay(for: date)
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "id == %@ AND date == %@",
            trackerId as CVarArg,
            date as NSDate
        )

        return try context.fetch(fetchRequest)
    }

    func fetchCompletedTrackerRecords(for trackerId: UUID) throws -> [TrackerRecordCoreData] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)

        return try context.fetch(fetchRequest)
    }
}

// MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        guard
            let tracker = trackerStore.tracker(by: trackerRecord.id)
        else {
            throw TrackerRecordStoreError.decodingErrorInvalidTrackerID
        }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = trackerRecord.id
        recordCoreData.date = Calendar.current.startOfDay(for: trackerRecord.date)
        recordCoreData.tracker = tracker
        
        DataStoreManager.shared.saveContext()
    }

    func removeTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let date = Calendar.current.startOfDay(for: trackerRecord.date)
        fetchRequest.predicate = NSPredicate(
            format: "id == %@ AND date == %@",
            trackerRecord.id as CVarArg,
            date as NSDate
        )
        
        let records = try context.fetch(fetchRequest)
        
        if let record = records.first {
            context.delete(record)
            DataStoreManager.shared.saveContext()
        }
    }

    func isTrackerCompletedToday(id: UUID, date: Date) -> Bool {
        do {
            let fetchRequest = TrackerRecordCoreData.fetchRequest()
            let date = Calendar.current.startOfDay(for: date)
            
            fetchRequest.predicate = NSPredicate(
                format: "id == %@ AND date == %@",
                id as CVarArg,
                date as NSDate
            )
            
            let records = try context.fetch(fetchRequest)
            return !records.isEmpty
        } catch {
            print("Error checking if tracker is completed: \(error)")
            return false
        }
    }

    func completedTrackersCount(for trackerId: UUID) -> Int {
        do {
            let fetchRequest = TrackerRecordCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
            
            let records = try context.fetch(fetchRequest)
            return records.count
        } catch {
            print("Error fetching completed trackers count: \(error)")
            return 0
        }
    }
}
