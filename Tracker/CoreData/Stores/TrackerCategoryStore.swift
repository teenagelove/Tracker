//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        self.init(context: DataStoreManager.shared.viewContext)
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", category.name)
        request.fetchLimit = 1

        let results = try context.fetch(request)

        if let existing = results.first {
            return existing
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.name = category.name
            return newCategory
        }
    }
}
