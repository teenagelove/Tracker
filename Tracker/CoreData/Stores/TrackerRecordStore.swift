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
    func getTotalCompletedTrackersCount() throws -> Int
    func getAverageScore() throws -> Int
    func getBestStreakCount() throws -> Int
    func getPerfectDaysCount() throws -> Int
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(
        context: NSManagedObjectContext = DataStoreManager.shared.viewContext
    ) {
        self.context = context
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
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerRecord.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        guard let tracker = try context.fetch(fetchRequest).first else {
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
    
    func getTotalCompletedTrackersCount() throws -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let records = try context.fetch(fetchRequest)
        return records.count
    }
    
    func getAverageScore() throws -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        let records = try context.fetch(fetchRequest)
        
        let calendar = Calendar.current
        let groupedByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date ?? Date.distantPast)
        }
        
        let totalDays = groupedByDate.keys.count
        let totalRecords = records.count
        
        guard totalDays > 0 else {
            return 0
        }
        
        return totalRecords / totalDays
    }
    
    func getBestStreakCount() throws -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let records = try context.fetch(fetchRequest)
        let calendar = Calendar.current
        
        let uniqueDates = Set(records.compactMap { record -> Date? in
            guard let date = record.date else { return nil }
            return calendar.startOfDay(for: date)
        }).sorted()
        
        guard !uniqueDates.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<uniqueDates.count {
            let prevDate = uniqueDates[i - 1]
            let currentDate = uniqueDates[i]
            
            if let expectedNextDay = calendar.date(byAdding: .day, value: 1, to: prevDate),
               calendar.isDate(expectedNextDay, inSameDayAs: currentDate) {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    func getPerfectDaysCount() throws -> Int {
        let recordsFetchRequest = TrackerRecordCoreData.fetchRequest()
        let records = try context.fetch(recordsFetchRequest)
        
        let calendar = Calendar.current
        let recordsByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date ?? Date.distantPast)
        }
        
        var perfectDaysCount = 0
        
        for (date, dailyRecords) in recordsByDate {
            let weekday = calendar.component(.weekday, from: date)
            let weekdayStr = "\(weekday)"
            
            let trackersFetchRequest = TrackerCoreData.fetchRequest()
            
            // Для регулярных трекеров смотрим на расписание
            let regularTrackersPredicate = NSPredicate(
                format: "schedule != nil AND schedule CONTAINS[c] %@",
                weekdayStr
            )
            
            // Для нерегулярных событий (schedule == nil), проверяем, выполнены ли они в этот день
            let completedIDsInDay = dailyRecords.compactMap { $0.id }
            var irregularTrackersPredicate: NSPredicate?
            
            if !completedIDsInDay.isEmpty {
                irregularTrackersPredicate = NSPredicate(
                    format: "schedule == nil AND id IN %@",
                    completedIDsInDay
                )
            }
            
            var predicates = [regularTrackersPredicate]
            if let irregular = irregularTrackersPredicate {
                predicates.append(irregular)
            }
            
            trackersFetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
            
            let plannedTrackers = try context.fetch(trackersFetchRequest)
            
            if plannedTrackers.isEmpty {
                continue
            }
            
            let completedTrackerIDs = Set(completedIDsInDay)
            
            let allTrackersCompleted = plannedTrackers.allSatisfy { tracker in
                completedTrackerIDs.contains(tracker.id ?? UUID())
            }
            
            if allTrackersCompleted {
                perfectDaysCount += 1
            }
        }
        
        return perfectDaysCount
    }
}
