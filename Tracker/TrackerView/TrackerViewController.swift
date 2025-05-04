//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 20.03.2025.
//

import UIKit

protocol TrackerViewControllerDelegate: AnyObject {
    func didReceiveNewTracker(tracker: Tracker, category: TrackerCategory, isEdit: Bool)
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
    private lazy var categoryStore: TrackerCategoryStore = {
        TrackerCategoryStore(delegate: self)
    }()
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        TrackerStore(categoryStore: categoryStore, delegate: self)
    }()
    
    private lazy var recordStore: TrackerRecordStoreProtocol = {
        TrackerRecordStore(trackerStore: trackerStore)
    }()
    
    private var currentDate = Date() {
        didSet {
            filterTrackers()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        filterTrackers()
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
    func filterTrackers() {
        let text = navigationItem.searchController?.searchBar.text ?? ""
        trackerStore.updateFilter(currentDate: currentDate, searchText: text)
        updateEmptyStateVisibility()
    }
    
    func updateEmptyStateVisibility() {
        if categoryStore.categories.count == 0 && trackerStore.trackers.count == 0 {
            emptyStateLabel.text = Constants.UIString.emptyStateLabel
            emptyStateImageView.image = .emptyStateStub
            emptyStateStackView.isHidden = false
        } else if trackerStore.trackers.isEmpty == true {
            emptyStateLabel.text = Constants.UIString.notFound
            emptyStateImageView.image = .emptyFilter
            emptyStateStackView.isHidden = false
        } else {
            emptyStateStackView.isHidden = true
        }
    }
    
    func isTrackerCompletedToday(id: UUID) -> Bool {
        recordStore.isTrackerCompletedToday(id: id, date: currentDate)
    }
    
    func completedTrackersCount(for trackerId: UUID) -> Int {
        recordStore.completedTrackersCount(for: trackerId)
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
        navigationItem.largeTitleDisplayMode = .always
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
        navigationItem.searchController?.searchBar.placeholder = Constants.UIString.search
        navigationItem.searchController?.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        navigationItem.hidesSearchBarWhenScrolling = false
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
        trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerStore.numbersOfRowsInSections(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let tracker = trackerStore.tracker(at: indexPath),
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
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: SupplementaryView.reuseIdentifier,
                for: indexPath
            ) as? SupplementaryView
        else { return SupplementaryView() }
        
        let header = trackerStore.nameOfSection(indexPath.section)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let firstIndexPath = indexPaths.first,
              let tracker = trackerStore.tracker(at: firstIndexPath)
        else { return nil }
        
        return UIContextMenuConfiguration(identifier: firstIndexPath as NSCopying, previewProvider: nil) { _ in
            let pinTitle = tracker.isPinned
            ? Constants.UIString.unPin
            : Constants.UIString.pin
            
            let pinImage = tracker.isPinned ? UIImage.unPin : UIImage.pin
            
            let pin = UIAction(title: pinTitle, image: pinImage) { _ in
                self.trackerStore.togglePin(for: tracker.id)
                self.filterTrackers()
            }
            
            let edit = UIAction(
                title: Constants.UIString.edit,
                image: .pencil
            ) { _ in
                self.editTracker(at: firstIndexPath)
            }
            
            let delete = UIAction(
                title: Constants.UIString.delete,
                image: .trash,
                attributes: .destructive
            ) { _ in
                self.deleteTracker(at: firstIndexPath)
            }
            
            return UIMenu(children: [pin, edit, delete])
        }
    }
    
    private func editTracker(at indexPath: IndexPath) {
        guard let tracker = trackerStore.tracker(at: indexPath) else { return }
        
        let categoryName = trackerStore.nameOfSection(indexPath.section)
        let category = TrackerCategory(name: categoryName, trackers: [])
        let isHabit = !tracker.schedule.isEmpty
        let record = recordStore.completedTrackersCount(for: tracker.id)
        
        let editViewController = NewHabitOrEventViewController(isHabit: isHabit, mode: .edit, delegate: self)
        
        editViewController.setTracker(tracker: tracker, category: category, record: record)
        
        present(UINavigationController(rootViewController: editViewController), animated: true)
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: Constants.UIString.deleteTrackerQuestion,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: Constants.UIString.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: Constants.UIString.delete, style: .destructive) { [weak self] _ in
            self?.trackerStore.deleteTracker(at: indexPath)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - TrackerViewControllerDelegate
extension TrackerViewController: TrackerViewControllerDelegate {
    func didReceiveNewTracker(tracker: Tracker, category: TrackerCategory, isEdit: Bool) {
        if isEdit {
            trackerStore.updateTracker(tracker: tracker, category: category)
        } else {
            try? trackerStore.addNewTracker(tracker: tracker, category: category)
        }
        
        filterTrackers()
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
        
        let record = TrackerRecord(id: trackerID, date: currentDate)
        
        if !isTrackerCompletedToday(id: trackerID) {
            try? recordStore.addTrackerRecord(record)
        } else {
            try? recordStore.removeTrackerRecord(record)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}


// MARK: - UISearchBarDelegate
extension TrackerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterTrackers()
    }
}

// MARK: - TrackerDataProviderDelegate
extension TrackerViewController: TrackerStoreDelegate {
    func didUpdateTrackers(_ update: TrackerStoreUpdate) {
        // Если все массивы пустые, значит сработал фильтр и надо обновить всю таблицу
        if update.deletedIndexPaths.isEmpty &&
            update.insertedIndexPaths.isEmpty &&
            update.deletedSections.isEmpty &&
            update.insertedSections.isEmpty {
            collectionView.reloadData()
            return
        }
        
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: update.deletedIndexPaths)
            collectionView.insertItems(at: update.insertedIndexPaths)
            collectionView.deleteSections(update.deletedSections)
            collectionView.insertSections(update.insertedSections)
            
            for move in update.movedIndexPaths {
                collectionView.moveItem(at: move.from, to: move.to)
            }
        }
        
        updateEmptyStateVisibility()
    }
}

// MARK: - TrackerCategoryStoreDelegate
extension TrackerViewController: TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerCategoryStoreUpdate) {
        collectionView.performBatchUpdates {
            collectionView.deleteSections(update.deletedIndexes)
            collectionView.insertSections(update.insertedIndexes)
            collectionView.reloadSections(update.updatedIndexes)
        }
    }
}
