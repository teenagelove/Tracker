//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 20.03.2025.
//

import UIKit

protocol TrackerViewControllerDelegate: AnyObject {
    func didReceiveNewTracker(tracker: Tracker)
}

final class TrackerViewController: UIViewController {
    // MARK: - UI Components
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(didPickerValueChanged(_:)), for: .valueChanged)
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    
    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .emptyStateStub
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.UIString.emptyStateLabel
        label.numberOfLines = 0
        label.font = .little
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emptyStateStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emptyStateImageView, emptyStateLabel])
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Properties
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            visibleCategories.isEmpty ? hideEmptyStateView(isHidden: false) : hideEmptyStateView(isHidden: true)
        }
    }
    private lazy var visibleCategories: [TrackerCategory] = categories
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate = Date() {
        didSet {
            filterTrackers()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Actions
private extension TrackerViewController {
    @objc func didPickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
    }
    
    @objc func addTracker() {
        let creating = CreationTrackerViewController(delegate: self)
        let navigationController = UINavigationController(rootViewController: creating)
        present(navigationController, animated: true)
    }
}

// MARK: - Private Methods
private extension TrackerViewController {
    func filterTrackers() {
//        let searchText = "Aa"
        let day = Calendar.current.component(.weekday, from: currentDate)
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
//                let textCondition = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
                
                let dateCondition = tracker.schedule.contains { week in
                    week.rawValue == day
                }
                
//                return textCondition && dateCondition
                return dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                header: category.header,
                trackers: trackers
            )
        }
        
        collectionView.reloadData()
//        filteredTrackers = trackers.filter { $0.date == currentDate }
    }
}

// MARK: - Setup Methods
private extension TrackerViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        view.addSubviews(collectionView, emptyStateStackView)
        setupNavigationBar()
        setupCollectionView()
        setupConstraints()
    }
    
    func setupNavigationBar() {
        navigationItem.title = Constants.UIString.trackers
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.toolbar.backgroundColor = .ypBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .plus,
            style: .plain,
            target: self,
            action: #selector(addTracker)
        )
        navigationItem.leftBarButtonItem?.tintColor = .ypAccent
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.searchController = UISearchController()
        // TODO: Убрать потом для локализации
        navigationItem.searchController?.searchBar.placeholder = Constants.UIString.search
        navigationItem.searchController?.searchBar.setValue("Отменить", forKey: "cancelButtonText")
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .ypBackground
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            TrackerHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderView.reuseIdentifier
            )
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK: - Private Methods
private extension TrackerViewController {
    func hideEmptyStateView(isHidden: Bool) {
        emptyStateStackView.isHidden = isHidden
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCollectionViewCell
        else { return TrackerCollectionViewCell() }
        
        cell.configureCell(
            tracker: visibleCategories[indexPath.section].trackers[indexPath.row],
            days: 1,
            isCompleted: false,
            delegate: self
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerHeaderView.reuseIdentifier,
            for: indexPath
        ) as? TrackerHeaderView
        else { return TrackerHeaderView() }
        
        view.setTitle(visibleCategories[indexPath.section].header)
        return view
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 2 - 32
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 30)
    }
}

// MARK: - TrackerViewControllerDelegate
extension TrackerViewController: TrackerViewControllerDelegate {
    func didReceiveNewTracker(tracker: Tracker) {
        if categories.isEmpty {
           let newCategory = TrackerCategory(header: "Пивная", trackers: [])
           categories.append(newCategory)
           visibleCategories = categories
           
            collectionView.performBatchUpdates {
                collectionView.insertSections(IndexSet(integer: 0))
            }
        }
        
        var category = categories[0]
        var updatedTrackers = category.trackers
        
        updatedTrackers.append(tracker)
        category = TrackerCategory(header: category.header, trackers: updatedTrackers)
        categories[0] = category
        
        filterTrackers()
    }
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func didTapPlusButton(in cell: TrackerCollectionViewCell) {
        guard
            currentDate <= Date()
//            let indexPath = collectionView.indexPath(for: cell)
            
        else { return }
        
//        var calendar = Calendar.current
//        calendar.firstWeekday = 2
//        
//        let day = calendar.component(.weekday, from: currentDate)
//        let trackerID = cell.trackerID
        cell.updateButton(isCompleted: true)
    }
}
