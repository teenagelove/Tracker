//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    var categories: [TrackerCategoryCoreData] { get }
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
    var categories: [TrackerCategoryCoreData] {
        let request = TrackerCategoryCoreData.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
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
