//
//  ScheduleTableViewCell.swift
//  Tracker
//
//  Created by Danil Kazakov on 04.04.2025.
//

import UIKit

protocol ScheduleTableViewCellDelegate: AnyObject {
    func switchToggled(title: String?, isEnable: Bool)
}

final class ScheduleTableViewCell: UITableViewCell  {
    // MARK: - UI Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .regular
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let control = UISwitch()
        control.onTintColor = .ypBlue
        control.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        return control
    }()
    
    // MARK: - Properties
    static let reuseIdentifier = "ScheduleCell"
    private weak var delegate: ScheduleTableViewCellDelegate?
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ScheduleTableViewCell {
    @objc func switchToggled(_ sender: UISwitch) {
        self.delegate?.switchToggled(title: titleLabel.text, isEnable: sender.isOn)
    }
}

// MARK: - Public Methods
extension ScheduleTableViewCell {
    func configure(with title: String, delegate: ScheduleTableViewCellDelegate) {
        self.delegate = delegate
        self.titleLabel.text = title
    }
}

// MARK: - Setup Methods
private extension ScheduleTableViewCell {
    func setupUI(){
        self.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        self.accessoryView = switchControl
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
