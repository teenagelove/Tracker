//
//  TrackerRecordDataProvider.swift
//  Tracker
//
//  Created by Danil Kazakov on 17.04.2025.
//

import UIKit
import CoreData

protocol TrackerRecordDataProviderProtocol {
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func removeTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func isTrackerCompletedToday(id: UUID, date: Date) -> Bool
    func completedTrackersCount(for trackerId: UUID) -> Int
}

final class TrackerRecordDataProvider: NSObject {
    private let dataStore: TrackerRecordStoreProtocol
    private let context: NSManagedObjectContext
    private let provider: TrackerDataProviderProtocol
    
    init(_ store: TrackerRecordStoreProtocol, trackerProvider: TrackerDataProviderProtocol) throws {
        self.context = DataStoreManager.shared.viewContext
        dataStore = store
        provider = trackerProvider
    }
}

// MARK: - TrackerRecordDataProviderProtocol
extension TrackerRecordDataProvider: TrackerRecordDataProviderProtocol {
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        guard
            let tracker = provider.trackerCoreData(by: trackerRecord.id)
        else {
            throw TrackerRecordStoreError.decodingErrorInvalidTrackerID
        }
        // TODO:  Если задать records.tracker, то это вызовет обновление в fetchedResultsController
        // Из-за этого начинает криво работать коллекция, как обойти - не придумал.
        // Использую хот-фикс как выключение делегата, чтобы не было обновления.
        provider.toggleDelegate()
        try dataStore.addTrackerRecord(trackerRecord, tracker: tracker)
        provider.toggleDelegate()
    }
    
    func removeTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        provider.toggleDelegate()
        try dataStore.removeTrackerRecord(trackerRecord)
        provider.toggleDelegate()
    }
    
    func isTrackerCompletedToday(id: UUID, date: Date) -> Bool {
        do {
            let records = try dataStore.fetchTrackerRecords(for: id, on: date)
            return !records.isEmpty
        } catch {
            print("Error checking if tracker is completed: \(error)")
            return false
        }
    }
    
    func completedTrackersCount(for trackerId: UUID) -> Int {
        do {
            let records = try dataStore.fetchCompletedTrackerRecords(for: trackerId)
            return records.count
        } catch {
            print("Error fetching completed trackers count: \(error)")
            return 0
        }
    }
}
