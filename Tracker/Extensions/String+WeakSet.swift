//
//  String+toWeakSet.swift
//  Tracker
//
//  Created by Danil Kazakov on 19.04.2025.
//

extension Optional where Wrapped == String {
    func toWeekSet() -> Set<Week> {
        guard let self, !self.isEmpty else { return [] }
        let rawValues = self.split(separator: ",").compactMap { Int($0) }
        return Set(rawValues.compactMap { Week(rawValue: $0) })
    }
}
