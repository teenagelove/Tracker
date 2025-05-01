//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.04.2025.
//

import UIKit

final class OnboardingViewController: UIViewController {
    private var image: UIImage
    private var text: String
    
    private lazy var imageView = UIImageView(frame: view.bounds)
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .onboarding
        label.textColor = .ypBlack
        return label
    }()
    
    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        textLabel.text = text
        
        view.addSubview(imageView)
        view.addSubviews(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
    }
}
