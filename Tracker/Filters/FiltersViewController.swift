//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 17.05.2025.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filterType: FilterType)
}

final class FiltersViewController: UIViewController {
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .ypBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = .systemGray
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.tableHeaderView = UIView()
        tableView.allowsMultipleSelection = false
        return tableView
    }()
    
    // MARK: - Properties
    private var selectedIndexPath: IndexPath?
    private var selectedFilterType: FilterType
    private weak var delegate: FiltersViewControllerDelegate?
    
    // MARK: - Initializers
    init(selectedFilterType: FilterType, delegate: FiltersViewControllerDelegate?) {
        self.selectedFilterType = selectedFilterType
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Setup Methods
private extension FiltersViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        view.addSubviews(tableView)
        setupNavigationBar()
        setupConstraints()
        setupFilter()
    }
    
    func setupFilter() {
        if let index = FilterType.allCases.firstIndex(of: selectedFilterType) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
    
    func setupNavigationBar() {
        navigationItem.title = Constants.UIString.filters
        navigationItem.hidesBackButton = true
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Insets.verticalInset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Insets.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Insets.horizontalInset),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(FilterType.allCases.count * 75)),
        ])
    }
}


// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FilterType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as? FilterCell else {
            return FilterCell()
        }
        
        let filterType = FilterType.allCases[indexPath.row]
        cell.configure(with: filterType.title)
        
        if indexPath.row == FilterType.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            cell.makeRounding()
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        if filterType == selectedFilterType {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        let filterType = FilterType.allCases[indexPath.row]
        selectedFilterType = filterType
        
        UserDefaults.standard.set(selectedFilterType.rawValue, forKey: FilterType.userDefaultsKey)
        
        delegate?.didSelectFilter(filterType)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
