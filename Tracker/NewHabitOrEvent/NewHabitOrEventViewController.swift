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
    
    
    // MARK: - Properties
    private weak var delegate: TrackerViewControllerDelegate?
    private var isHabit: Bool
    private var schedule: Set<Week> = []
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                          "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                          "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    private let colors: [UIColor] = [.typeRed, .typeOrange, .typeBlue, .typeLilac, .typeGreen,
                                     .typePink, .typeSalmon, .typeBrightBlue, .typeLightGreen,
                                     .typeDeepBlue, .typeBrightRed, .typeLightPink, .typeLightOrange,
                                     .typeLightBlue, .typeViolet, .typeLightViolet, .typeLightLilac,
                                     .typeBrightGreen]
    
    // MARK: - Initializate
    init(isHabit: Bool, delegate: TrackerViewControllerDelegate) {
        self.isHabit = isHabit
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

// MARK: - Actions
private extension NewHabitOrEventViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func cancelButtonDidTap() {
        dismiss(animated: true)
    }
    
    @objc func applyButtonDidTap() {
        let tracker = Tracker(
            id: UUID(),
            name: textField.text?.trimmingCharacters(in: .whitespaces) ?? "",
            color: .typeSalmon,
            emoji: "🍺",
            schedule: schedule
        )
        
        delegate?.didReceiveNewTracker(tracker: tracker)
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - Private Methods
private extension NewHabitOrEventViewController {
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
            return "Пивная категория"
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
            self.isHabit ? !trimmedText.isEmpty && !schedule.isEmpty : !trimmedText.isEmpty
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
        view.addSubviews(textField, tableView, buttonsStack, collectionView)
        view.addGestureRecognizer(tapGesture)
        setupConstraints()
    }
    
    func setupNavigationBar() {
        let title = isHabit ? Constants.UIString.newHabit : Constants.UIString.newEvent
        navigationItem.title = title
        navigationItem.hidesBackButton = true
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            
            // TODO: Stub
            tableView.heightAnchor.constraint(equalToConstant: isHabit ? 75 * 2 : 75),
            
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 50),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -16),
        ])
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
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.makeRounding()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NewHabitOrEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Category did tap")
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
        guard let section = Section(rawValue: indexPath.section),
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SupplementaryView.reuseIdentifier,
            for: indexPath
        ) as! SupplementaryView
        header.setTitle(section.title)
        return header
    }
}

// MARK: - UICollectionViewFlowDelegate
extension NewHabitOrEventViewController: UICollectionViewDelegateFlowLayout {
    
}
