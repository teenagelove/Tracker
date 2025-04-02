//
//  NewHabitOrEventCell.swift
//  Tracker
//
//  Created by Danil Kazakov on 02.04.2025.
//

import UIKit

final class NewHabitOrEventCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let image = UIImageView()
        image.image = .chevron
        return image
    }()
    
    static let reuseIdentifier = "cell"
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods
extension NewHabitOrEventCell {
    func setTitle(title: String) {
        titleLabel.text = title
    }
}

// MARK: - Setup Methods
private extension NewHabitOrEventCell {
    func setupUI(){
        contentView.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.addSubviews(titleLabel, chevronImageView)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            chevronImageView.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 24),
            chevronImageView.widthAnchor.constraint(equalTo: chevronImageView.heightAnchor)
        ])
    }
}
