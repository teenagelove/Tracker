//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Danil Kazakov on 19.05.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class MainTabBarControllerSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }
    
    func testTabBarControllerLightTheme() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .light

        let tabBarVC = TabBarViewController()
        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        assertSnapshot(
            of: tabBarVC,
            as: .image(traits: .init(userInterfaceStyle: .light)),
            named: "light_theme"
        )
    }

    func testTabBarControllerDarkTheme() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.overrideUserInterfaceStyle = .dark

        let tabBarVC = TabBarViewController()
        window.rootViewController = tabBarVC
        window.makeKeyAndVisible()

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 1))

        assertSnapshot(
            of: tabBarVC,
            as: .image(traits: .init(userInterfaceStyle: .dark)),
            named: "dark_theme"
        )
    }
}

