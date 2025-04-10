//
//  Untitled.swift
//  Tracker
//
//  Created by Danil Kazakov on 10.04.2025.
//

import UIKit

class ColorCell: UICollectionViewCell {
    // MARK: - UI Components
    private let colorView: UIView = {
        let colorView = UIView()
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        return colorView
    }()
    
    // MARK: - Properties
    static let reusableIdentifier = "ColorCell"
    
    // MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods
extension ColorCell {
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
        setupBGView()
    }
}

// MARK: - Private Methods
private extension ColorCell {
    private func setupBGView() {
        let selectedBG = UIView()
        selectedBG.layer.cornerRadius = 8
        selectedBG.layer.borderWidth = 3
        selectedBG.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
        self.selectedBackgroundView = selectedBG
    }
}

// MARK: - Setup Methods
private extension ColorCell {
    func setupUI() {
        contentView.addSubviews(colorView)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
    }
}
