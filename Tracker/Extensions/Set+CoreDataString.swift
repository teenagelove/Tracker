//
//  Set+toCoreDataString.swift
//  Tracker
//
//  Created by Danil Kazakov on 19.04.2025.
//

extension Set where Element == Week {
    func toCoreDataString() -> String? {
        guard !self.isEmpty else { return nil }
        return self.map { "\($0.rawValue)" }.sorted().joined(separator: ",")
    }
}
