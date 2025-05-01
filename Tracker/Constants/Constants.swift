//
//  Constants.swift
//  Tracker
//
//  Created by Danil Kazakov on 21.03.2025.
//

import Foundation

enum Constants {
    enum UIString {
        static let emptyStateLabel = "Что будем отслеживать?"
        static let trackers = "Трекеры"
        static let statistic = "Статистика"
        static let search = "Поиск"
        static let creatingTracker = "Создание трекера"
        static let habit = "Привычка"
        static let event = "Нерегулярное событие"
        static let newHabit = "Новая привычка"
        static let newEvent = "Новое нерегулярное событие"
        static let newCategory = "Новая категория"
        static let trackerPlaceholder = "Введите название трекера"
        static let categoryPlaceholder = "Введите название категории"
        static let category = "Категория"
        static let schedule = "Расписание"
        static let cancel = "Отменить"
        static let apply = "Применить"
        static let submit = "Готово"
        static let notFound = "Ничего не найдено"
        static let emoji = "Emoji"
        static let color = "Цвет"
        static let defaultCategory = "Пивная"
        static let skipOnboarding = "Вот это технологии!"
        static let onboardingFirstTitle = "Отслеживайте только то, что хотите"
        static let onboardingSecondTitle = "Даже если это  не литры воды и йога"
        static let stubEmptyCategoryText = "Привычки и события можно  объединить по смыслу"
        static let addNewCategory = "Добавить категорию"
        static let edit = "Редактировать"
        static let delete = "Удалить"
    }
    
    enum Keys {
        static let isShowedOnboarding = "isShowedOnboarding"
    }
    
    enum Insets {
        static let horizontalInset = CGFloat(16)
    }
}
