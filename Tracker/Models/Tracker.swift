//
//  Tracker.swift
//  Tracker
//
//  Created by Danil Kazakov on 23.03.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Week>
}

