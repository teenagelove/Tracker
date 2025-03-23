//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 20.03.2025.
//

import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - UI Components
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(.plusButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.UIString.trackers
        label.font = Constants.Fonts.title
        return label
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
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.addSubviews(addButton, emptyStateLabel, emptyStateImageView, titleLabel)
        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
}
