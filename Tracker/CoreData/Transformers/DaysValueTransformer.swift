//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        NSString.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? Set<Week> else { return nil }
        let rawValues = days.map { "\($0.rawValue)" }.sorted()
        let string = rawValues.joined(separator: ",")
        return string.data(using: .utf8)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        let components = string.split(separator: ",").compactMap { Int($0) }
        let weeks = components.compactMap { Week(rawValue: $0) }
        return Set(weeks)
    }
    
    static func register() {
        let name = NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        ValueTransformer.setValueTransformer(DaysValueTransformer(), forName: name)
    }
}
