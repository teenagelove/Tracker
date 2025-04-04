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
        label.font = .regular
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Пивная категория"
        label.font = .regular
        label.tintColor = .ypGray
        return label
    }()
    
    // MARK: - Properties
    static let reuseIdentifier = "NewHabitCell"
    
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
    
    func makeRounding() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

// MARK: - Setup Methods
private extension NewHabitOrEventCell {
    func setupUI(){
        self.accessoryType = .disclosureIndicator
        self.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        contentView.addSubviews(titleLabel)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
