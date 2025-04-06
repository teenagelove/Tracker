//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Danil Kazakov on 25.03.2025.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapPlusButton(in cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ypGray.withAlphaComponent(0.3).cgColor
        view.backgroundColor = .typeSalmon
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .little
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        return label
    }()
    
    private lazy var cardTextLabel: UILabel = {
        let label = UILabel()
        label.font = .little
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var recordLabel: UILabel = {
        let label = UILabel()
        label.font = .little
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.plusRecord, for: .normal)
        button.contentMode = .center
        button.tintColor = .ypWhite
        button.backgroundColor = .typeSalmon
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(plusButtonDidTap), for: .primaryActionTriggered)
        return button
    }()
    
    // MARK: - Properties
    private weak var delegate: TrackerCellDelegate?
    private(set) var trackerID: UUID?
    
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
extension TrackerCollectionViewCell {
    func configureCell(tracker: Tracker, days: Int, isCompleted: Bool, delegate: TrackerCellDelegate) {
        trackerID = tracker.id
        cardView.backgroundColor = tracker.color
        recordLabel.text = "\(days) \(days.dayWord)"
        plusButton.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        cardTextLabel.text = tracker.name
        updateButton(isCompleted: isCompleted)
        self.delegate = delegate
    }
}

// MARK: - Actions
private extension TrackerCollectionViewCell {
    @objc func plusButtonDidTap() {
        delegate?.didTapPlusButton(in: self)
    }
}

// MARK: - Private Methods
private extension TrackerCollectionViewCell {
    func updateButton(isCompleted: Bool) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self else { return }
            
            self.plusButton.setImage(isCompleted ? .checkmark : .plusRecord, for: .normal)
            self.plusButton.alpha = isCompleted ? 0.3 : 1
        }
    }
}

// MARK: - Setup Methods
private extension TrackerCollectionViewCell {
    func setupUI() {
        setupSubviews()
        setupConstraints()
    }
    
    func setupSubviews() {
        contentView.addSubviews(cardView, recordLabel, plusButton)
        cardView.addSubviews(cardTextLabel, emojiLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            recordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            recordLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            cardTextLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            cardTextLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            cardTextLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalTo: plusButton.heightAnchor),
            
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalTo: emojiLabel.heightAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12)
        ])
    }
}
