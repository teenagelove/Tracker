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
}
