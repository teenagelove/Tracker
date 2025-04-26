//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.04.2025.
//

import UIKit

final class OnboardingViewController: UIViewController {
    private let image: UIImage
    private let imageView = UIImageView()
    
    init(image: UIImage) {
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.frame = view.bounds
        imageView.image = image
        view.addSubview(imageView)
    }
}
