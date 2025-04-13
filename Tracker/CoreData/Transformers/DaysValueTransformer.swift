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
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? Set<Week> else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard
            let data = value as? NSData,
            let decoded = try? JSONDecoder().decode([Week].self, from: data as Data)
        else { return nil }
        return Set(decoded)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
