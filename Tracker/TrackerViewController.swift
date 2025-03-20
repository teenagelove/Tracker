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
        button.tintColor = .ypBlack
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

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
        view.addSubviews(addButton)
        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6)
        ])
    }
}
