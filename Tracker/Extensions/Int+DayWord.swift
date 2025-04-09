//
//  Int+DayWord.swift
//  Tracker
//
//  Created by Danil Kazakov on 06.04.2025.
//

extension Int {
    var dayWord: String {
        let lastDigit = self % 10
        let lastTwoDigits = self % 100

        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "дней"
        }

        switch lastDigit {
        case 1:
            return "день"
        case 2, 3, 4:
            return "дня"
        default:
            return "дней"
        }
    }
}
