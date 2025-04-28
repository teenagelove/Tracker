//
//  CategoryCell.swift
//  Tracker
//
//  Created by Danil Kazakov on 28.04.2025.
//

import UIKit

final class CategoryCell: UITableViewCell  {
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .regular
        return label
    }()
    
    // MARK: - Properties
    static let reuseIdentifier = "CategoryCell"
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.cornerRadius = 0
        layer.maskedCorners = []
        selectedBackgroundView?.layer.cornerRadius = 0
        selectedBackgroundView?.layer.maskedCorners = []
    }
}

// MARK: - Public Methods
extension CategoryCell {
    func configure(with title: String) {
        self.titleLabel.text = title
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
private extension CategoryCell {
    func setupUI(){
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
