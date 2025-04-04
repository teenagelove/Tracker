//
//  Week.swift
//  Tracker
//
//  Created by Danil Kazakov on 04.04.2025.
//

enum Week: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var title: String {
            switch self {
            case .monday: return "Понедельник"
            case .tuesday: return "Вторник"
            case .wednesday: return "Среда"
            case .thursday: return "Четверг"
            case .friday: return "Пятница"
            case .saturday: return "Суббота"
            case .sunday: return "Воскресенье"
            }
        }
}

// MARK: - Init
extension Week {
    init?(title: String) {
        guard let week = Week.allCases.first(where: { $0.title == title }) else {
            return nil
        }
        self = week
    }
}
