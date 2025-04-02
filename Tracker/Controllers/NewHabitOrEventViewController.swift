//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.03.2025.
//

import UIKit

final class NewHabitOrEventViewController: UIViewController {
    // MARK: - UI Components
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.placeholder = Constants.UIString.trackerPlaceholder
        textField.textAlignment = .left
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(NewHabitOrEventCell.self, forCellReuseIdentifier: NewHabitOrEventCell.reuseIdentifier)
        return tableView
    }()
    
    // MARK: - Properties
    private var isHabit: Bool
    
    // MARK: - Initializate
    init(isHabit: Bool) {
        self.isHabit = isHabit
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

// MARK: - Actions
extension NewHabitOrEventViewController {

}

// MARK: - Private Methods
private extension NewHabitOrEventViewController {
    func getTitleFromRow(for row: Int) -> String {
        var title: String = ""
        
        switch row {
        case 0:
            title = Constants.UIString.category
        case 1:
            title = Constants.UIString.schedule
        default:
            break
        }
        
        return title
    }
}

// MARK: - Setup Methods
private extension NewHabitOrEventViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        setupNavigationBar()
        view.addSubviews(textField, tableView)
        setupConstraints()
    }
    
    func setupNavigationBar() {
        let title = isHabit ? Constants.UIString.newHabit : Constants.UIString.newEvent
        navigationItem.title = title
        navigationItem.hidesBackButton = true
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        ])
    }
}


// MARK: - UITableViewDataSource
extension NewHabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isHabit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: NewHabitOrEventCell.reuseIdentifier, for: indexPath) as? NewHabitOrEventCell
        else { return NewHabitOrEventCell() }
        
        cell.setTitle(title: getTitleFromRow(for: indexPath.row))
        
        return cell
    }
}
// MARK: - UITableViewDelegate
extension NewHabitOrEventViewController: UITableViewDelegate {
    
}
