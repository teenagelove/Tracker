//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 28.04.2025.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var stubText: UILabel = {
        let label = UILabel()
        label.text = Constants.UIString.stubEmptyCategoryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .little
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyStateStub
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStateStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stubImage, stubText])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.tableHeaderView = UIView()
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    
    private lazy var addNewCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.UIString.addNewCategory, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypAccent
        button.titleLabel?.font = .medium
        button.setTitleColor(.ypBackground, for: .normal)
        button.addTarget(self, action: #selector(addNewCategoryDidTap), for: .primaryActionTriggered)
        return button
    }()
    
    // MARK: - Properties
    private var viewModel: CategoryViewModelProtocol = CategoryViewModel()
    private let selectedCategory: TrackerCategory?
    private var selectedIndexPath: IndexPath?
    private let categorySelectedCompletion: (TrackerCategory) -> Void
    
    // MARK: - Initializer
    init(selectedCategory: TrackerCategory?, completion: @escaping (TrackerCategory) -> Void) {
        self.selectedCategory = selectedCategory
        self.categorySelectedCompletion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        updateStubsVisibility()
    }
}

// MARK: - Actions
private extension CategoryViewController {
    @objc func addNewCategoryDidTap() {
        let newCategoryController = NewCategoryController(
            categoryName: nil,
            onCategoryAdded:  { [weak self] categoryName in
                guard let self else { return }
                let newCategory = TrackerCategory(name: categoryName, trackers: [])
                self.viewModel.addCategory(newCategory)
            },
            onCategoryUpdated: nil
        )
        navigationController?.pushViewController(newCategoryController, animated: true)
    }
    
    func bindViewModel() {
        viewModel.categoriesBinding = { [weak self] _ in
            guard let self else { return }
            
            if let selectedCategory = self.selectedCategory {
                if let index = self.viewModel.categories.firstIndex(where: { $0.name == selectedCategory.name }) {
                    self.selectedIndexPath = IndexPath(row: index, section: 0)
                }
            }
            
            tableView.reloadData()
            updateStubsVisibility()
        }
        
        if let binding = viewModel.categoriesBinding {
            binding(viewModel.categories)
        }
    }
}

// MARK: - Private Methods
private extension CategoryViewController {
    func updateStubsVisibility() {
        emptyStateStackView.isHidden = !viewModel.categories.isEmpty
        tableView.isHidden = viewModel.categories.isEmpty
    }
    
    private func editCategory(at indexPath: IndexPath) {
        let oldCategory = viewModel.categories[indexPath.row]
        let editVC = NewCategoryController(
            categoryName: oldCategory.name,
            onCategoryAdded: nil,
            onCategoryUpdated:  { [weak self] newName in
                try? self?.viewModel.updateCategory(oldName: oldCategory.name, newName: newName)
            })
        navigationController?.pushViewController(editVC, animated: true)
    }
}

// MARK: - Setup Methods
private extension CategoryViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        view.addSubviews(tableView, addNewCategoryButton, emptyStateStackView)
        setupNavigationBar()
        setupConstraints()
    }
    
    func setupNavigationBar() {
        navigationItem.title = Constants.UIString.category
        navigationItem.hidesBackButton = true
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stubImage.heightAnchor.constraint(equalToConstant: 80),
            stubImage.widthAnchor.constraint(equalToConstant: 80),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addNewCategoryButton.topAnchor, constant: -16),
            
            addNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addNewCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            return CategoryCell()
        }
        
        let category = viewModel.categories[indexPath.row]
        cell.configure(with: category.name)
        
        if selectedIndexPath == indexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if indexPath.row == viewModel.categories.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            cell.makeRounding()
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
            
            let selectedCategory = viewModel.categories[indexPath.row]
            categorySelectedCompletion(selectedCategory)
            
            cell.accessoryType = .checkmark
            
            tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: Constants.UIString.edit, image: .pencil,
            ) { [weak self] _ in
                self?.editCategory(at: indexPath)
            }
            
            let deleteAction = UIAction(
                title: Constants.UIString.delete, image: .trash,
                attributes: .destructive
            ) { [weak self] _ in
                self?.deleteCategory(at: indexPath)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
        
        let alert = UIAlertController(
            title: Constants.UIString.deleteCategoryQuestion,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: Constants.UIString.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.UIString.delete, style: .destructive) { [weak self] _ in
            try? self?.viewModel.deleteCategory(category)
        })
        
        present(alert, animated: true)
    }
}
