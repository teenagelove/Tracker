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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.report(event: "open", screen: "Main")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.report(event: "close", screen: "Main")
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
        
        let statisticView = UINavigationController(rootViewController: StatisticViewController())
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
