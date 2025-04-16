//
//  TrackerCategoryProvider.swift
//  Tracker
//
//  Created by Danil Kazakov on 16.04.2025.
//

import CoreData

protocol TrackerCategoryProviderProtocol {
    var categories: [String] { get }
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
    var categories: [String] {
        store.categories.map { $0.name ?? "" }
    }
    
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData {
        try store.fetchOrCreateCategory(from: category)
    }
}
