//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Danil Kazakov on 13.04.2025.
//

import CoreData

protocol TrackerCategoryStoreProtocol {
    var categories: [String] { get }
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = DataStoreManager.shared.viewContext) {
        self.context = context
    }
}

// MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    var categories: [String] {
        let request = TrackerCategoryCoreData.fetchRequest()
        do {
            let results = try context.fetch(request)
            return results.map { $0.name ?? "" }
        } catch {
            print("Failed to fetch category names: \(error)")
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
