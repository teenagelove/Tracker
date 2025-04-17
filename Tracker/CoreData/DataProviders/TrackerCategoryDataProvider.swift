//
//  TrackerCategoryProvider.swift
//  Tracker
//
//  Created by Danil Kazakov on 16.04.2025.
//

import CoreData

protocol TrackerCategoryDataProviderProtocol {
    var categories: [String] { get }
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryDataProvider {
    private let context: NSManagedObjectContext
    private let store: TrackerCategoryStoreProtocol

    init(_ store: TrackerCategoryStoreProtocol) throws {
        self.context = DataStoreManager.shared.viewContext
        self.store = store
    }
}

// MARK: - TrackerCategoryProviderProtocol
extension TrackerCategoryDataProvider: TrackerCategoryDataProviderProtocol {
    var categories: [String] {
        store.categories.map { $0.name ?? "" }
    }
    
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData {
        try store.fetchOrCreateCategory(from: category)
    }
}
