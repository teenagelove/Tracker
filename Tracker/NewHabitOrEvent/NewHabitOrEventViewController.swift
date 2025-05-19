//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Danil Kazakov on 26.03.2025.
//

import UIKit

enum Section: Int, CaseIterable {
    case emoji
    case color
    
    var title: String {
        switch self {
        case .emoji: return Constants.UIString.emoji
        case .color: return Constants.UIString.color
        }
    }
}

enum Mode: Int {
    case create, edit
}

protocol NewHabitOrEventViewControllerDelegate: AnyObject {
    func didReceiveSchedule(schedule: Set<Week>)
}

final class NewHabitOrEventViewController: UIViewController {
    // MARK: - UI Components
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.placeholder = Constants.UIString.trackerPlaceholder
        textField.textAlignment = .left
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            NewHabitOrEventCell.self,
            forCellReuseIdentifier: NewHabitOrEventCell.reuseIdentifier
        )
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .ypBackground
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Constants.UIString.cancel, for: .normal)
        button.titleLabel?.font = .medium
        button.setTitleColor(.ypRed, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .primaryActionTriggered)
        return button
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypGray
        button.setTitle(Constants.UIString.apply, for: .normal)
        button.setTitleColor(.ypBackground, for: .normal)
        button.titleLabel?.font = .medium
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(applyButtonDidTap), for: .primaryActionTriggered)
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        return tapGesture
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemsPerRow: CGFloat = 6
        let spacing: CGFloat = 5
        let outerMargin: CGFloat = 18
        let width = (UIScreen.main.bounds.width - outerMargin * 2 - spacing * (itemsPerRow - 1)) / itemsPerRow
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSize(
            width: UIScreen.main.bounds.width - outerMargin * 2,
            height: 30
        )
        layout.sectionInset = UIEdgeInsets(top: 24, left: outerMargin, bottom: 24, right: outerMargin)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.allowsMultipleSelection = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            EmojiCell.self,
            forCellWithReuseIdentifier: EmojiCell.reusableIdentifier
        )
        collectionView.register(
            ColorCell.self,
            forCellWithReuseIdentifier: ColorCell.reusableIdentifier
        )
        collectionView.register(
            SupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SupplementaryView.reuseIdentifier
        )
        return collectionView
    }()
    
    private lazy var recordLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypAccent
        label.font = .onboarding
        label.textAlignment = .center
        label.isHidden = mode == .create
        return label
    }()
    
    
    // MARK: - Properties
    private weak var delegate: TrackerViewControllerDelegate?
    private var isHabit: Bool
    private var schedule: Set<Week> = []
    private var mode: Mode
    private var editingTracker: Tracker?
    
    private var selectedCategory: TrackerCategory? {
        didSet {
            updateStateApplyButton()
        }
    }
    
    private var selectedEmoji: (emoji: String?, indexPath: IndexPath?) {
        didSet {
            updateStateApplyButton()
        }
    }
    
    private var selectedColor: (color: UIColor?, indexPath: IndexPath?) {
        didSet {
            updateStateApplyButton()
        }
    }
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                          "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                          "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    private let colors: [UIColor] = [.typeRed, .typeOrange, .typeBlue, .typeLilac, .typeGreen,
                                     .typePink, .typeSalmon, .typeBrightBlue, .typeLightGreen,
                                     .typeDeepBlue, .typeBrightRed, .typeLightPink, .typeLightOrange,
                                     .typeLightBlue, .typeViolet, .typeLightViolet, .typeLightLilac,
                                     .typeBrightGreen]
    
    // MARK: - Initializate
    init(isHabit: Bool, mode: Mode, delegate: TrackerViewControllerDelegate) {
        self.isHabit = isHabit
        self.mode = mode
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - Public Methods
extension NewHabitOrEventViewController {
    func setTracker(tracker: Tracker, category: TrackerCategory, record: Int) {
        editingTracker = tracker
        textField.text = tracker.name
        selectedCategory = category
        schedule = tracker.schedule
        recordLabel.text = String.localizedStringWithFormat(
            NSLocalizedString(Constants.UIString.completedDays, comment: ""),
            record,
        )
        
        tableView.reloadData()
        collectionView.reloadData()
        
        selectEmoji(tracker.emoji)
        selectColor(tracker.color)
        
        updateStateApplyButton()
    }
}

// MARK: - Actions
private extension NewHabitOrEventViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func cancelButtonDidTap() {
        dismiss(animated: true)
    }
    
    @objc func applyButtonDidTap() {
        guard let selectedCategory else { return }
        
        let trackerID = editingTracker?.id ?? UUID()
        let isPinned = editingTracker?.isPinned ?? false
        
        let tracker = Tracker(
            id: trackerID,
            name: textField.text?.trimmingCharacters(in: .whitespaces) ?? "",
            color: selectedColor.color ?? .typeSalmon,
            emoji: selectedEmoji.emoji ?? "🍺",
            schedule: schedule,
            isPinned: isPinned
        )
        
        let isEdit = mode == .edit
        
        delegate?.didReceiveNewTracker(tracker: tracker, category: selectedCategory, isEdit: isEdit)
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - Private Methods
private extension NewHabitOrEventViewController {
    func selectEmoji(_ emoji: String) {
        guard let emojiIndex = emojis.firstIndex(of: emoji) else { return }
        
        let emojiIndexPath = IndexPath(item: emojiIndex, section: Section.emoji.rawValue)
        selectedEmoji = (emoji, emojiIndexPath)
        collectionView.selectItem(at: emojiIndexPath, animated: false, scrollPosition: [])
    }
    
    func selectColor(_ color: UIColor) {
        guard let colorIndex = colors.firstIndex(where: { $0.isEqual(color) }) else { return }
        
        let colorIndexPath = IndexPath(item: colorIndex, section: Section.color.rawValue)
        selectedColor = (color, colorIndexPath)
        collectionView.selectItem(at: colorIndexPath, animated: false, scrollPosition: [])
    }
    
    func getTitleFromRow(for row: Int) -> String {
        switch row {
        case 0:
            return Constants.UIString.category
        case 1:
            return Constants.UIString.schedule
        default:
            return ""
        }
    }
    
    func getSubtitleFromRow(for row: Int) -> String? {
        switch row {
        case 0:
            return selectedCategory?.name ?? nil
        case 1:
            return schedule.isEmpty ? nil : getScheduleShortTitle()
        default:
            return nil
        }
    }
    
    func getScheduleShortTitle() -> String {
        if schedule.count == 7 {
            return "Каждый день"
        }
        
        let sortedDays = schedule.sorted {
            let value1 = $0.rawValue == 1 ? 8 : $0.rawValue
            let value2 = $1.rawValue == 1 ? 8 : $1.rawValue
            return value1 < value2
        }
        
        return sortedDays.map { $0.shortTitle }.joined(separator: ", ")
    }
    
    func updateStateApplyButton() {
        let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        var isValid: Bool {
            let hasText = !trimmedText.isEmpty
            let hasSchedule = isHabit ? !schedule.isEmpty : true
            let hasEmoji = selectedEmoji.emoji != nil
            let hasColor = selectedColor.color != nil
            let hasCategory = selectedCategory != nil
            
            return hasText && hasSchedule && hasEmoji && hasColor && hasCategory
        }
        
        applyButton.isEnabled = isValid
        applyButton.backgroundColor = isValid ? .ypAccent : .ypGray
    }
}

// MARK: - Setup Methods
private extension NewHabitOrEventViewController {
    func setupUI() {
        view.backgroundColor = .ypBackground
        setupNavigationBar()
        view.addSubviews(textField, recordLabel, tableView, buttonsStack, collectionView)
        view.addGestureRecognizer(tapGesture)
        setupConstraints()
    }
    
    func setupNavigationBar() {
        let title = {
            if self.isHabit && self.mode == .create {
                return Constants.UIString.newHabit
            } else if self.isHabit && self.mode == .edit {
                return Constants.UIString.editTracker
            } else if !self.isHabit && self.mode == .create {
                return Constants.UIString.newEvent
            } else {
                return Constants.UIString.editEvent
            }
        }()
        
        navigationItem.title = title
        navigationItem.hidesBackButton = true
    }
    
    func setupConstraints() {
        var constraints: [NSLayoutConstraint] = [
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Insets.horizontalInset),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Insets.horizontalInset),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Insets.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Insets.horizontalInset),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            
            tableView.heightAnchor.constraint(equalToConstant: isHabit ? 75 * 2 : 75),
            
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -Constants.Insets.horizontalInset),
            
            recordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Insets.horizontalInset),
            recordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Insets.horizontalInset),
            recordLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ]
        
        if mode == .create {
            constraints.append(
                textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
            )
        } else {
            constraints.append(
                textField.topAnchor.constraint(equalTo: recordLabel.bottomAnchor, constant: 40)
            )
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}


// MARK: - UITableViewDataSource
extension NewHabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isHabit ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: NewHabitOrEventCell.reuseIdentifier, for: indexPath) as? NewHabitOrEventCell
        else { return NewHabitOrEventCell() }
        
        let title = getTitleFromRow(for: indexPath.row)
        let subtitle = getSubtitleFromRow(for: indexPath.row)
        cell.configure(title: title, subtitle: subtitle)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            cell.makeRounding()
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewHabitOrEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let categoryViewController = CategoryViewController(selectedCategory: selectedCategory) { [weak self] category in
                guard let self else { return }
                self.selectedCategory = category
                
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            navigationController?.pushViewController(categoryViewController, animated: true)
        case 1:
            navigationController?.pushViewController(
                ScheduleViewController(
                    schedule: schedule,
                    delegate: self
                ),
                animated: true
            )
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

// MARK: - UITextFieldDelegate
extension NewHabitOrEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateStateApplyButton()
    }
}

// MARK: - NewHabitOrEventViewControllerDelegate
extension NewHabitOrEventViewController: NewHabitOrEventViewControllerDelegate {
    func didReceiveSchedule(schedule: Set<Week>) {
        self.schedule = schedule
        updateStateApplyButton()
        let indexPath = IndexPath(row: 1, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}


// MARK: - UICollectionViewDataSource
extension NewHabitOrEventViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .emoji: return emojis.count
        case .color: return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            assertionFailure("Invalid section")
            return UICollectionViewCell()
        }
        
        switch section {
        case .emoji:
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EmojiCell.reusableIdentifier,
                    for: indexPath
                ) as? EmojiCell
            else {
                assertionFailure("Failed to dequeue EmojiCell or index out of bounds")
                return UICollectionViewCell()
            }
            
            cell.configure(with: emojis[indexPath.item])
            return cell
            
        case .color:
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ColorCell.reusableIdentifier,
                    for: indexPath
                ) as? ColorCell
            else {
                assertionFailure("Failed to dequeue ColorCell or index out of bounds")
                return UICollectionViewCell()
            }
            
            cell.configure(with: colors[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            let section = Section(rawValue: indexPath.section),
            kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SupplementaryView.reuseIdentifier,
                for: indexPath
            ) as? SupplementaryView
        else {
            assertionFailure("Failed to dequeue SupplementaryView or invalid section/kind")
            return UICollectionReusableView()
        }
        
        header.configure(section.title)
        return header
    }
}

// MARK: - UICollectionViewFlowDelegate
extension NewHabitOrEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section)
        else {
            assertionFailure("Invalid section")
            return
        }
        
        switch section {
        case .emoji:
            if let previous = selectedEmoji.indexPath, previous != indexPath {
                collectionView.deselectItem(at: previous, animated: true)
            }
            selectedEmoji.indexPath = indexPath
            selectedEmoji.emoji = emojis[indexPath.item]
            
        case .color:
            if let previous = selectedColor.indexPath, previous != indexPath {
                collectionView.deselectItem(at: previous, animated: true)
            }
            selectedColor.indexPath = indexPath
            selectedColor.color = colors[indexPath.item]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section)
        else {
            assertionFailure("Invalid section")
            return
        }
        
        switch section {
        case .emoji:
            if selectedEmoji.indexPath == indexPath {
                selectedEmoji.indexPath = nil
                selectedEmoji.emoji = nil
            }
            
        case .color:
            if selectedColor.indexPath == indexPath {
                selectedColor.indexPath = nil
                selectedColor.color = nil
            }
        }
    }
}
