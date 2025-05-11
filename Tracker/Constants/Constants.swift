//
//  Constants.swift
//  Tracker
//
//  Created by Danil Kazakov on 21.03.2025.
//

import Foundation

enum Constants {
    enum UIString {
        // MARK: - Onboarding
        static let onboardingFirstTitle = NSLocalizedString("onboarding.first.title", comment: "")
        static let onboardingSecondTitle = NSLocalizedString("onboarding.second.title", comment: "")
        static let skipOnboarding = NSLocalizedString("onboarding.skip", comment: "")

        // MARK: - Stubs
        static let emptyStateLabel = NSLocalizedString("stub.empty.tracker.title", comment: "")
        static let stubEmptyCategoryText = NSLocalizedString("stub.empty.category.text", comment: "")
        static let notFound = NSLocalizedString("stub.empty.filter.title", comment: "")
        static let trackerPlaceholder = NSLocalizedString("stub.empty.category.placeholder", comment: "")
        static let categoryPlaceholder = NSLocalizedString("stub.empty.tracker.placeholder", comment: "")

        // MARK: - Tracker
        static let trackers = NSLocalizedString("trackers.title", comment: "")
        static let habit = NSLocalizedString("tracker.title", comment: "")
        static let emoji = NSLocalizedString("tracker.emoji", comment: "")
        static let color = NSLocalizedString("tracker.color", comment: "")
        static let event = NSLocalizedString("tracker.event.title", comment: "")
        static let newHabit = NSLocalizedString("tracker.new.title", comment: "")
        static let newEvent = NSLocalizedString("tracker.event.new.title", comment: "")
        static let editTracker = NSLocalizedString("tracker.edit.title", comment: "")
        static let editEvent = NSLocalizedString("tracker.edit.event.title", comment: "")
        static let creatingTracker = NSLocalizedString("tracker.create.title", comment: "")
        static let schedule = NSLocalizedString("tracker.schedule", comment: "")
        static let deleteTrackerQuestion = NSLocalizedString("delete.tracker.question", comment: "")
        static let completedDays = "tracker.completed.days"

        // MARK: - Category
        static let category = NSLocalizedString("category.title", comment: "")
        static let defaultCategory = NSLocalizedString("default.category.title", comment: "")
        static let newCategory = NSLocalizedString("new.category.title" , comment: "")
        static let addNewCategory = NSLocalizedString("add.new.category" , comment: "")
        static let deleteCategoryQuestion = NSLocalizedString("delete.category.question" , comment: "")
        
        // MARK: - Actions
        static let apply = NSLocalizedString("action.apply", comment: "")
        static let cancel = NSLocalizedString("action.cancel", comment: "")
        static let submit = NSLocalizedString("action.submit", comment: "")
        static let edit = NSLocalizedString("action.edit", comment: "")
        static let delete = NSLocalizedString("action.delete", comment: "")
        static let pin = NSLocalizedString("action.pin", comment: "")
        static let unPin = NSLocalizedString("action.unpin", comment: "")
        static let pinned = NSLocalizedString("action.pinned", comment: "")

        // MARK: - Statistic
        static let statistic = NSLocalizedString("statistic.title", comment: "")

        // MARK: - Search
        static let search = NSLocalizedString("search.title", comment: "")
    }
    
    enum Keys {
        static let isShowedOnboarding = "isShowedOnboarding"
    }
    
    enum Insets {
        static let horizontalInset = CGFloat(16)
    }
}
