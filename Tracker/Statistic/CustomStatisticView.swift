//
//  CustomView.swift
//  Tracker
//
//  Created by Danil Kazakov on 14.05.2025.
//

import UIKit

final class CustomStatisticView: UIView {
    // MARK: - UI Components
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .title
        label.textColor = .ypAccent
        label.textAlignment = .left
        return label
    }()
    
    private lazy var statsNameLabel: UILabel = {
        let label = UILabel()
        label.font = .little
        label.textColor = .ypAccent
        label.textAlignment = .left
        return label
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.typeRed.cgColor,
            UIColor.typeLightGreen.cgColor,
            UIColor.typeBlue.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect){
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientLayer()
    }
}

// MARK: - Public Methods
extension CustomStatisticView {
    func updateView(count: Int, name: String) {
        countLabel.text = String(count)
        statsNameLabel.text = name
    }
}

// MARK: - Setup Methods
private extension CustomStatisticView {
    func setupUI() {
        backgroundColor = .ypBackground
        clipsToBounds = true
        layer.cornerRadius = 16
        addSubviews(statsNameLabel, countLabel)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            statsNameLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 7),
            statsNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            statsNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            statsNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
    
    func setupGradientLayer() {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        let innerPath = UIBezierPath(roundedRect: CGRect(
            x: 1,
            y: 1,
            width: bounds.width - 2,
            height: bounds.height - 2
        ), cornerRadius: 15)
        
        path.append(innerPath.reversing())
        maskLayer.path = path.cgPath
        
        gradientLayer.frame = bounds
        gradientLayer.mask = maskLayer
        
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        layer.addSublayer(gradientLayer)
    }
}
