//
//  TrackerHeaderView.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.03.2025.
//

import UIKit

final class SupplementaryView: UICollectionReusableView {
    // MARK: - Properties
    static let reuseIdentifier = "SupplementaryView"
    
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .header
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializate
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods
extension SupplementaryView {
    func configure(_ title: String) {
        titleLabel.text = title
    }
}
