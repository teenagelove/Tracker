//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.04.2025.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    // MARK: - UI Components
    private lazy var pages: [UIViewController] = {
        let blueVC = OnboardingViewController(
            image: .onboardingBlueBackground,
            text: Constants.UIString.onboardingFirstTitle
        )
        
        let redVC = OnboardingViewController(
            image: .onboardingRedBackground,
            text: Constants.UIString.onboardingSecondTitle
        )
        
        return [blueVC, redVC]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        return pageControl
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.UIString.skipOnboarding, for: .normal)
        button.titleLabel?.font = .medium
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Actions
private extension OnboardingPageViewController {
    @objc func didTapCompleteButton() {
        UserDefaults.standard.set(true, forKey: Constants.Keys.isShowedOnboarding)
        UIApplication.shared.windows.first?.rootViewController = TabBarViewController()
    }
}

// MARK: - Setup Methods
private extension OnboardingPageViewController {
    func setupUI() {
        dataSource = self
        delegate = self
        setupSubviews()
        setupConstraint()
    }
    
    func setupSubviews() {
        if let first = pages.first {
            setViewControllers(
                [first],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
        
        view.addSubviews(pageControl, completeButton)
    }
    
    func setupConstraint() {
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -10),
            
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
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
        
        return newIndex < 0 ? pages.last : pages[newIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let viewControllerIndex = pages.firstIndex(of: viewController)
        else { return nil }
        
        let newIndex = viewControllerIndex + 1
        
        return newIndex >= pages.count ? pages.first : pages[newIndex]
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
