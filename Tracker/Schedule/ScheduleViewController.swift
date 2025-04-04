//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 04.04.2025.
//

import UIKit

final class ScheduleViewController: UIViewController {
    // MARK: - UI Components
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.UIString.submit, for: .normal)
        button.setTitleColor(.ypBackground, for: .normal)
        button.backgroundColor = .ypAccent
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(submitButtonTapped), for: .primaryActionTriggered)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .ypBackground
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.tableHeaderView = UIView()
        tableView.allowsSelection = false
        return tableView
    }()
    
    // MARK: - Properties
    private let daysOfWeek = Week.allCases.map { $0.title }
    private var selectedDays: Set<Week> = []
    private weak var delegate: NewHabitOrEventViewControllerDelegate?
    
    // MARK: - Initilizate
    init(delegate: NewHabitOrEventViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Actions
private extension ScheduleViewController {
    @objc func submitButtonTapped() {
        delegate?.didReceiveSchedule(schedule: selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Setup Methods
private extension ScheduleViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        view.addSubviews(tableView, submitButton)
        setupNavigationBar()
        setupConstraints()
    }
    
    func setupNavigationBar() {
        navigationItem.title = Constants.UIString.schedule
        navigationItem.hidesBackButton = true
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * daysOfWeek.count)),
            
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath) as? ScheduleTableViewCell
        else { return ScheduleTableViewCell() }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        let day = daysOfWeek[indexPath.row]
        cell.configure(with: day, delegate: self)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - ScheduleTableViewCellDelegate
extension ScheduleViewController: ScheduleTableViewCellDelegate {
    func switchToggled(title: String?, isEnable: Bool) {
        guard let day = Week(title: title ?? "") else { return }
        
        if isEnable {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
}
