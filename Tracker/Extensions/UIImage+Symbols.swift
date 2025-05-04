//
//  Image+Symbols.swift
//  Tracker
//
//  Created by Danil Kazakov on 20.03.2025.
//

import UIKit

extension UIImage {
    static let record = UIImage(systemName: "record.circle.fill")
    static let statistic = UIImage(systemName: "hare.fill")
    static let plus = UIImage(
        systemName: "plus",
        withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
    )
    static let plusRecord = UIImage(
        systemName: "plus",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 11)
    )
    static let checkmark = UIImage(
        systemName: "checkmark",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 11)
    )
    
    static let trash = UIImage(systemName: "trash")
    static let pencil = UIImage(systemName: "pencil")
    static let pin = UIImage(systemName: "pin.fill")
    static let unPin = UIImage(systemName: "pin.slash")
    
    static let pinIcon = UIImage(
        systemName: "pin.fill",
        withConfiguration: UIImage.SymbolConfiguration(
            pointSize: 11
        )
    )
}
