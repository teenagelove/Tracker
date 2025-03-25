//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 20.03.2025.
//

import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - UI Components
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyStateStub
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.UIString.emptyStateLabel
        label.numberOfLines = 0
        label.font = Constants.Fonts.medium
        label.textAlignment = .center
        return label
    }()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Setup Methods
private extension TrackerViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        view.addSubviews(emptyStateLabel, emptyStateImageView)
        setupNavigationBar()
        setupConstraints()
    }
    
    func setupNavigationBar() {
        navigationItem.title = Constants.UIString.trackers
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .plusButton, style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
