//
//  TrackerCategoryProvider.swift
//  Tracker
//
//  Created by Danil Kazakov on 16.04.2025.
//

import CoreData

protocol TrackerCategoryProviderProtocol {
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryProvider {
    private let context: NSManagedObjectContext
    private let store: TrackerCategoryStoreProtocol

    init(context: NSManagedObjectContext) {
        self.context = context
        self.store = TrackerCategoryStore(context: context)
    }
    
    convenience init() {
        self.init(context: DataStoreManager.shared.viewContext)
    }
}

// MARK: - TrackerCategoryProviderProtocol
extension TrackerCategoryProvider: TrackerCategoryProviderProtocol {
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData {
        try store.fetchOrCreateCategory(from: category)
    }
}
