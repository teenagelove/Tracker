//
//  StatisticViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 20.03.2025.
//

import UIKit

final class StatisticViewController: UIViewController {
    // MARK: - UI Components
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.UIString.emptyStatistic
        label.numberOfLines = 0
        label.font = .little
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stubImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyStatistic
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stubStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stubImageView, stubLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    private lazy var bestStreakView: CustomView = {
        let view = CustomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var perfectDaysView: CustomView = {
        let view = CustomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var completedTrackersView: CustomView = {
        let view = CustomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var averageScoreView: CustomView = {
        let view = CustomView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statisticStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                bestStreakView,
                perfectDaysView,
                completedTrackersView,
                averageScoreView
            ]
        )
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 12
        return stack
    }()
    
    // MARK: - Properties
    private lazy var recordStore = TrackerRecordStore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistic()
    }
}

// MARK: - Public Methods
extension StatisticViewController {
    func updateStatistic() {
        let records = try? recordStore.getTotalCompletedTrackersCount()
        if let records, records > 0 {
            stubStackView.isHidden = true
            statisticStackView.isHidden = false
            getStatistics()
        } else {
            stubStackView.isHidden = false
            statisticStackView.isHidden = true
        }
    }
}

// MARK: - Private Methods
private extension StatisticViewController {
    func getStatistics() {
        guard
            let bestStreak = try? recordStore.getBestStreakCount(),
            let perfectDays = try? recordStore.getPerfectDaysCount(),
            let completedTrackers = try? recordStore.getTotalCompletedTrackersCount(),
            let averageScore = try? recordStore.getAverageScore()
        else { return }
        
        let statistics: [(count: Int, name: String)] = [
            (bestStreak, Constants.UIString.bestStreak),
            (perfectDays, Constants.UIString.perfectDays),
            (completedTrackers, Constants.UIString.completedTrackers),
            (averageScore, Constants.UIString.averageScore)
        ]
        
        let views = [bestStreakView, perfectDaysView, completedTrackersView, averageScoreView]
        
        for (view, stat) in zip(views, statistics) {
            view.updateView(count: stat.count, name: stat.name)
        }
    }
}

// MARK: - Setup Methods
private extension StatisticViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        view.addSubviews(stubStackView, statisticStackView)
        setupNavigationBar()
        setupConstraints()
    }
    
    func setupNavigationBar() {
        navigationItem.title = Constants.UIString.statistic
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.toolbar.backgroundColor = .ypBackground
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            
            statisticStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Insets.horizontalInset),
            statisticStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Insets.horizontalInset),
            statisticStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
