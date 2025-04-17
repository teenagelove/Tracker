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
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }()
    
    // MARK: - Properties
    private lazy var trackerProvider: TrackerDataProviderProtocol? = {
        let trackerStore = TrackerStore()
        return try? TrackerDataProvider(trackerStore, delegate: self)
    }()
    
    private lazy var recordProvider: TrackerRecordDataProviderProtocol? = {
        guard let trackerProvider else { return nil }
        let recordStore = TrackerRecordStore()
        return try? TrackerRecordDataProvider(recordStore, trackerProvider: trackerProvider)
    }()
    
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            updateEmptyStateVisibility()
        }
    }
    
    private lazy var visibleCategories: [TrackerCategory] = categories {
        didSet {
            updateEmptyStateVisibility()
        }
    }
    
    private var currentDate = Date() {
        didSet {
            filterTrackers2()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        filterTrackers2()
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
    
    @objc func dismissKeyboard() {
        navigationItem.searchController?.searchBar.endEditing(true)
        navigationItem.searchController?.dismiss(animated: true)
    }
}

// MARK: - Private Methods
private extension TrackerViewController {
    func filterTrackers2() {
        let text = navigationItem.searchController?.searchBar.text ?? ""
        trackerProvider?.updateFilter(currentDate: currentDate, searchText: text)
        updateEmptyStateVisibility()
    }
    
    func filterTrackers() {
        let day = Calendar.current.component(.weekday, from: currentDate)
        let searchBarText = navigationItem.searchController?.searchBar.text ?? ""
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = searchBarText.isEmpty || tracker.name.lowercased().contains(searchBarText.lowercased())
                
                var dateCondition: Bool {
                    if tracker.schedule.isEmpty {
                        let completions = completedTrackers.filter { $0.id == tracker.id }
                        
                        return completions.isEmpty || completions.contains {
                            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
                        }
                    } else {
                        return tracker.schedule.contains { $0.rawValue == day }
                    }
                }
                
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                name: category.name,
                trackers: trackers
            )
        }
        
        collectionView.reloadData()
    }
    
    func updateEmptyStateVisibility() {
       if trackerProvider?.categoriesCount == 0 {
            emptyStateLabel.text = Constants.UIString.emptyStateLabel
            emptyStateImageView.image = .emptyStateStub
            emptyStateStackView.isHidden = false
        } else if trackerProvider?.trackers.isEmpty == true {
            emptyStateLabel.text = Constants.UIString.notFound
            emptyStateImageView.image = .emptyFilter
            emptyStateStackView.isHidden = false
        } else {
            emptyStateStackView.isHidden = true
        }
    }
    
    func isTrackerCompletedToday(id: UUID) -> Bool {
        recordProvider?.isTrackerCompletedToday(id: id, date: currentDate) ?? false
    }
    
    func completedTrackersCount(for trackerId: UUID) -> Int {
        recordProvider?.completedTrackersCount(for: trackerId) ?? 0
    }
}

// MARK: - Setup Methods
private extension TrackerViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        view.addSubviews(collectionView, emptyStateStackView)
        view.addGestureRecognizer(tapGesture)
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
        navigationItem.searchController?.searchBar.delegate = self
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
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SupplementaryView.reuseIdentifier
        )
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerProvider?.numberOfSections ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: - Change Name
        trackerProvider?.numbersOfRowsInSections(in: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let tracker = trackerProvider?.tracker(at: indexPath),
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCollectionViewCell
        else { return TrackerCollectionViewCell() }
        
        let trackerViewModel = TrackerViewModel(
            tracker: tracker,
            isCompletedToday: isTrackerCompletedToday(id: tracker.id),
            completedDays: completedTrackersCount(for: tracker.id)
        )
        
        cell.configureCell(trackerViewModel,delegate: self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            let header = trackerProvider?.nameOfSection(indexPath.section),
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SupplementaryView.reuseIdentifier,
                for: indexPath
            ) as? SupplementaryView
        else { return SupplementaryView() }
        
        view.configure(header)
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
        if trackerProvider?.categoriesCount == 0 {
            let newCategory = TrackerCategory(name: "Пивная", trackers: [])
            try? trackerProvider?.addNewTracker(tracker: tracker, category: newCategory)
        } else {
            let category = TrackerCategory(name: trackerProvider?.nameOfSection(0) ?? "Пивная", trackers: [])
            try? trackerProvider?.addNewTracker(tracker: tracker, category: category)
        }
        
        filterTrackers2()
    }
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func didTapPlusButton(in cell: TrackerCollectionViewCell) {
        guard
            currentDate <= Date(),
            let trackerID = cell.trackerID,
            let indexPath = collectionView.indexPath(for: cell)
        else { return }
        
        let day = Calendar.current.startOfDay(for: currentDate)
        let record = TrackerRecord(id: trackerID, date: day)
        
        if !isTrackerCompletedToday(id: trackerID) {
            try? recordProvider?.addTrackerRecord(record)
        } else {
            try? recordProvider?.removeTrackerRecord(record)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}


// MARK: - UISearchBarDelegate
extension TrackerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers2()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterTrackers2()
    }
}

// MARK: - TrackerDataProviderDelegate
extension TrackerViewController: TrackerDataProviderDelegate {
    func didUpdateTrackers(_ update: TrackerStoreUpdate) {
        if update.insertedIndexPaths.isEmpty &&
            update.deletedIndexPaths.isEmpty &&
            update.insertedSections.isEmpty &&
            update.deletedSections.isEmpty {
            
            collectionView.reloadData()
            return
        }
        
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: update.deletedIndexPaths)
            collectionView.insertItems(at: update.insertedIndexPaths)
            collectionView.deleteSections(update.deletedSections)
            collectionView.insertSections(update.insertedSections)
        }
    }
}
