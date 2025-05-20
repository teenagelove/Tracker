//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Danil Kazakov on 28.04.2025.
//

typealias CategoryBinding<T> = (T) -> Void

protocol CategoryViewModelProtocol {
    var categories: [TrackerCategory] { get }
    var categoriesBinding: CategoryBinding<[TrackerCategory]>? { get set }
    func addCategory(_ category: TrackerCategory)
    func deleteCategory(_ category: TrackerCategory) throws
    func updateCategory(oldName: String, newName: String) throws
}

final class CategoryViewModel {
    
    // MARK: - Properties
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(categories)
        }
    }
    
    var categoriesBinding: CategoryBinding<[TrackerCategory]>?
    
    // MARK: - Initializers
    init(store: TrackerCategoryStoreProtocol) {
        trackerCategoryStore = store
        categories = fetchCategoriesFromStore()
    }
    
    convenience init() {
        let store = TrackerCategoryStore(delegate: nil)
        self.init(store: store)
    }
}

// MARK: - Private Methods
private extension CategoryViewModel {
    func fetchCategoriesFromStore() -> [TrackerCategory] {
        trackerCategoryStore.fetchCategories()
    }
}

// MARK: - CategoryViewModelProtocol
extension CategoryViewModel: CategoryViewModelProtocol {
    func addCategory(_ category: TrackerCategory) {
        do {
            let _ = try trackerCategoryStore.fetchOrCreateCategory(from: category)
            categories = fetchCategoriesFromStore()
        } catch {
            print("Failed to add category: \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        try trackerCategoryStore.deleteCategory(category)
        categories = fetchCategoriesFromStore()
    }
    
    func updateCategory(oldName: String, newName: String) throws {
        try trackerCategoryStore.updateCategory(oldName: oldName, newName: newName)
        categories = fetchCategoriesFromStore()
    }
}
