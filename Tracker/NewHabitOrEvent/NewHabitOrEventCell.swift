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
        label.font = .regular
        label.textColor = .ypGray
        label.isHidden = true
        return label
    }()
    
    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
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
    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        if let subtitle = subtitle, !subtitle.isEmpty {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
    
    func makeRounding() {
        layer.masksToBounds = true
        layer.cornerRadius = 16
        selectedBackgroundView?.layer.cornerRadius = 16
        selectedBackgroundView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

// MARK: - Setup Methods
private extension NewHabitOrEventCell {
    func setupUI(){
        accessoryType = .disclosureIndicator
        backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        contentView.addSubviews(verticalStack)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            verticalStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
