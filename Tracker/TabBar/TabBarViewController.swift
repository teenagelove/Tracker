//
//  ViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 20.03.2025.
//

import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupControllers()
        addBorder()
    }
}

// MARK: - Setup Methods
private extension TabBarViewController {
    func setupTabBar(){
        tabBarController?.tabBar.backgroundColor = .ypBackground
    }
    
    func setupControllers() {
        let trackerView = UINavigationController(rootViewController: TrackerViewController())
        trackerView.tabBarItem = UITabBarItem(
            title: Constants.UIString.trackers,
            image: .record,
            tag: 0
        )
        
        let statisticView = StatisticViewController()
        statisticView.tabBarItem = UITabBarItem(
            title: Constants.UIString.statistic,
            image: .statistic,
            tag: 1
        )

        viewControllers = [trackerView, statisticView]
    }
    
    func addBorder() {
        let borderView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: tabBar.frame.width,
                height: 0.5
            )
        )
        borderView.backgroundColor = .ypGray
        tabBar.addSubview(borderView)
    }
}
