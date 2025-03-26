//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.03.2025.
//

import UIKit

final class CreateHabitViewController: UIViewController {
    // MARK: - UI Components
    private lazy var habitTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.textAlignment = .left
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 16
        textField.attributedPlaceholder = NSAttributedString(
            string: Constants.UIString.trackerPlaceholder,
            attributes: [.paragraphStyle: paragraphStyle]
        )
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        return textField
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Actions
extension CreateHabitViewController {
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
private extension CreateHabitViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        navigationItem.title = Constants.UIString.newHabit
        navigationItem.hidesBackButton = true
        view.addSubviews(habitTextField)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            habitTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            habitTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
}
