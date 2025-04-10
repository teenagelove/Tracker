//
//  TrackerHeaderView.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.03.2025.
//

import UIKit

final class SupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = "SupplementaryView"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .header
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    func setTitle(_ title: String) {
        self.titleLabel.text = title
    }
}
