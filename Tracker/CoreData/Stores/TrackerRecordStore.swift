//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import Foundation
import CoreData

import UIKit
import CoreData

protocol TrackerRecordStoreProtocol {
    func addTrackerRecord(_ trackerRecord: TrackerRecord, tracker: TrackerCoreData) throws
    func removeTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func fetchTrackerRecords(for trackerId: UUID, on date: Date) throws -> [TrackerRecordCoreData]
    func fetchCompletedTrackerRecords(for trackerId: UUID) throws -> [TrackerRecordCoreData]
}

enum TrackerRecordStoreError: Error {
    case decodingErrorInvalidTrackerID
    case decodingErrorInvalidDate
    case entityCreationError
}

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        self.init(context: DataStoreManager.shared.viewContext)
    }
}

// MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore {
    func addTrackerRecord(_ trackerRecord: TrackerRecord, tracker: TrackerCoreData) throws {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = trackerRecord.id
        recordCoreData.date = trackerRecord.date
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
    
    func fetchTrackerRecords(for trackerId: UUID, on date: Date) throws -> [TrackerRecordCoreData] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        return try context.fetch(fetchRequest)
    }
    
    func fetchCompletedTrackerRecords(for trackerId: UUID) throws -> [TrackerRecordCoreData] {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        return try context.fetch(fetchRequest)
    }
}
