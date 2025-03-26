//
//  CreatingTrackerViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.03.2025.
//

import UIKit

final class CreatingTrackerViewController: UIViewController {
    // MARK: - UI Components
    private lazy var createHabitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.UIString.habit, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .medium
        button.titleLabel?.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createHabitButtonTapped), for: .primaryActionTriggered)
        return button
    }()
    
    private lazy var createEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.UIString.event, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .medium
        button.titleLabel?.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(createEventButtonTapped), for: .primaryActionTriggered)
        return button
    }()
    
    private lazy var stackButtons: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [createHabitButton, createEventButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Actions
extension CreatingTrackerViewController {
    @objc func createHabitButtonTapped() {
        let createHabitViewController = CreateHabitViewController()
        navigationController?.pushViewController(createHabitViewController, animated: true)
    }
    
//    @objc func createEventButtonTapped() {
//        let createEventViewController = CreateEventViewController()
//        navigationController?.pushViewController(createEventViewController, animated: true)
//    }
}

// MARK: - Setup Methods
private extension CreatingTrackerViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        navigationItem.title = Constants.UIString.creatingTracker
        view.addSubviews(stackButtons)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackButtons.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            createHabitButton.heightAnchor.constraint(equalToConstant: 60),
            createEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
