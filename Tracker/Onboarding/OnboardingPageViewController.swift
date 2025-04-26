//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.04.2025.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    private lazy var pages: [UIViewController] = {
        let blueVC = OnboardingViewController(image: .onboardingBlueBackground)
        let redVC = OnboardingViewController(image: .onboardingRedBackground)
        return [blueVC, redVC]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        return pageControl
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.UIString.skipOnboarding, for: .normal)
        button.setTitleColor(.ypBackground, for: .normal)
        button.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Actions
private extension OnboardingPageViewController {
    @objc func didTapCompleteButton() {
//        UserDefaults.standard.set(true, forKey: Constants.UIString.skipOnboarding)
        UIApplication.shared.windows.first?.rootViewController = TabBarViewController()
    }
}

// MARK: - Setup Methods
private extension OnboardingPageViewController {
    func setupUI() {
        dataSource = self
        delegate = self
    }
    
    func setupConstraint() {
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -10),
            
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            completeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let viewControllerIndex = pages.firstIndex(of: viewController)
        else { return nil }
        
        let newIndex = viewControllerIndex - 1
        
        if newIndex < 0 {
            return pages.last
        }
        
        return pages[newIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let viewControllerIndex = pages.firstIndex(of: viewController)
        else { return nil }
        
        let newIndex = viewControllerIndex + 1
        
        if newIndex > pages.count {
            return pages.first
        }
        
        return pages[newIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard
            let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = pages.firstIndex(of: currentViewController)
        else { return }
        
        pageControl.currentPage = currentIndex
    }
}
