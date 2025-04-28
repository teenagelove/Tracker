//
//  UIColorTransformer.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import UIKit

@objc(UIColorTransformer)
final class UIColorTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
        } catch {
            print("Failed to encode UIColor: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
        } catch {
            print("Failed to decode UIColor: \(error)")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            UIColorTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: UIColorTransformer.self))
        )
    }
}
