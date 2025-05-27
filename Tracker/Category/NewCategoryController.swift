//
//  NewCategoryController.swift
//  Tracker
//
//  Created by Danil Kazakov on 28.04.2025.
//

import UIKit

final class NewCategoryController: UIViewController {
    // MARK: - UI Components
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .ypLightGray
        textField.placeholder = Constants.UIString.categoryPlaceholder
        textField.textAlignment = .left
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypGray
        button.setTitle(Constants.UIString.apply, for: .normal)
        button.setTitleColor(.ypBackground, for: .normal)
        button.titleLabel?.font = .medium
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(applyButtonDidTap), for: .primaryActionTriggered)
        return button
    }()
    
    // MARK: - Properties
    private let onCategoryAdded: ((String) -> Void)?
    private let onCategoryUpdated: ((String) -> Void)?
    private var currentCategoryName: String?
    
    // MARK: - Initializers
    init(
        categoryName: String?,
        onCategoryAdded: ((String) -> Void)?,
        onCategoryUpdated: ((String) -> Void)?
    ) {
        currentCategoryName = categoryName
        self.onCategoryAdded = onCategoryAdded
        self.onCategoryUpdated = onCategoryUpdated
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.text = currentCategoryName
        setupUI()
    }
}

// MARK: - Actions
private extension NewCategoryController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func applyButtonDidTap() {
        guard
            let categoryName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !categoryName.isEmpty
        else { return }
        
        if let _ = currentCategoryName {
            onCategoryUpdated?(categoryName)
        } else {
            onCategoryAdded?(categoryName)
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Private Methods
private extension NewCategoryController {
    func updateStateApplyButton() {
        let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var isValid: Bool {
            return !trimmedText.isEmpty
        }
        
        applyButton.isEnabled = isValid
        applyButton.backgroundColor = isValid ? .ypAccent : .ypGray
    }
}

// MARK: - Setup Methods
private extension NewCategoryController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        view.addSubviews(textField, applyButton)
        view.addGestureRecognizer(tapGesture)
        setupNavigationBar()
        setupConstraints()
    }
    
    func setupNavigationBar() {
        navigationItem.title = Constants.UIString.newCategory
        navigationItem.hidesBackButton = true
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            applyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            applyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            applyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            applyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension NewCategoryController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateStateApplyButton()
    }
}
