//
//  TrackerCategoryProvider.swift
//  Tracker
//
//  Created by Danil Kazakov on 16.04.2025.
//


protocol TrackerCategoryDataProviderProtocol {
    var categories: [String] { get }
    func fetchOrCreateCategory(from category: TrackerCategory) throws -> TrackerCategoryCoreData
}

final class TrackerCategoryDataProvider {
    private let store: TrackerCategoryStoreProtocol

    init(_ store: TrackerCategoryStoreProtocol) throws {
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
