//
//  EmojiCell.swift
//  Tracker
//
//  Created by Danil Kazakov on 10.04.2025.
//

import UIKit

class EmojiCell: UICollectionViewCell {
    // MARK: - UI Components
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Properties
    static let reusableIdentifier = "EmojiCell"
    
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
extension EmojiCell {
    func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
}

// MARK: - Setup Methods
private extension EmojiCell {
    func setupUI() {
        contentView.addSubview(emojiLabel)
        emojiLabel.frame = contentView.bounds
        setupBGView()
    }
    
    func setupBGView() {
        let selectedBG = UIView()
        selectedBG.layer.cornerRadius = 8
        selectedBG.backgroundColor = UIColor.ypLightGray
        self.selectedBackgroundView = selectedBG
    }
}
