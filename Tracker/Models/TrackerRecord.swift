//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Danil Kazakov on 23.03.2025.
//
import Foundation

struct TrackerRecord {
    let id: UUID;
    let date: Date;
}

// MARK: - Hashable
extension TrackerRecord: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(date)
    }
        
    static func == (lhs: TrackerRecord, rhs: TrackerRecord) -> Bool {
        return lhs.id == rhs.id && Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)
    }
}
