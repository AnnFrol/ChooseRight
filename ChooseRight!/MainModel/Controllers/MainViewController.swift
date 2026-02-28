//
//  MainViewController.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 23.04.2023.
//

import Foundation
import UIKit
import CoreData

class MainViewController: UIViewController, UIViewControllerTransitioningDelegate, UIDocumentPickerDelegate {
    
    var dismissGesture = UITapGestureRecognizer()
    
    let warningMessageEmoji = ["😉", "💁‍♂️", "👻", "🙀", "🥈", "🚧", "❣️", "🥸", "👯", "🙃", "🧐", "🤓", "🤔"]
    
    weak var saveButtonInAlertChanged: UIAlertAction?
    
    let sharedDataBase = CoreDataManager.shared
    
    var settingsMenu = UIMenu()
    
    public var createNewComparisonListAlert:
    UIAlertController? = UIAlertController(
        title: NSLocalizedString("Create new comparison", comment: ""),
        message: "",
        preferredStyle: .alert)
    
    public var deleteComparisonConfirmationAlert:
    UIAlertController? = UIAlertController(
        title: NSLocalizedString("Delete comparison?", comment: ""),
        message: "",
        preferredStyle: .actionSheet)
    
    public var createNameChangingAlert:
    UIAlertController? = UIAlertController(
        title: NSLocalizedString("Rename your comparison", comment: ""),
        message: "",
        preferredStyle: .alert)
    
    let objectDetailsViewController = ObjectDetailsViewController()
    
    public var comparisonsArray = [ComparisonEntity]()
    let sectionsHardCode = 10
    let rowsHardCode = 1
    
    public var tableViewActive: Bool = false
    
    private var tableViewTopAnchor: NSLayoutConstraint?
    private var titleStackTopAnchor: NSLayoutConstraint?
    
    var tableViewSectionsCount = 0
    
    let topGradientLayer = CAGradientLayer()
    let bottomGradientLayer = CAGradientLayer()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString(string: "Tap the button to create your first comparison",
                                                         attributes:
                                                            [NSAttributedString.Key.kern: -0.15])
        label.font = .sfProTextMedium24()
        label.alpha = 0/*.8*/
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .specialColors.detailsOptionTableText
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    var cellMenu = UIMenu()
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString(string: "Choose Right!",
                                                         attributes:
                                                            [NSAttributedString.Key.kern: -1.37])
        label.font = .sfProTextBold33()
        label.textColor = UIColor(named: "specialText")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor(named: "specialText")
        let image = UIImage(systemName: "ellipsis")
        button.setImage((image), for: .normal)
        
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var titleStackView = UIStackView()
    
    lazy var addButton = AddButton()
    
    let tableView = MainTableView()
    
    private var bottomInset: Int = 0
    var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    let mainLabelContainer: UIView = {
        let view = UIView()
        view.alpha = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let statusBarGradientView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.layoutIfNeeded()
//        self.view.alpha = 0
        
        self.navigationController?.navigationBar.isHidden = true
        getData()
        updateMenu()
        
//        ScreenOrientationUtility.lockOrientation(.portrait)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        
//        ScreenOrientationUtility.lockOrientation(.all)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS 26: контент не должен заходить под статус-бар (изменения safe area в iOS 26)
        if #available(iOS 26.0, *) {
            edgesForExtendedLayout = [.bottom]
        }
        
        setupViews()
        setConstraints()
        setBottomInset()
        setDelegate()
        setupAccessibility()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenu), name: .didChangeTheme, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenu), name: .premiumStatusChanged, object: nil)
        
        
    }
    
    
    private func setupViews() {
        
        titleStackView = UIStackView(
            arrangedSubviews: [
                mainLabel,
                settingsButton
        ],
            axis: .horizontal,
            spacing: 20)
        titleStackView.distribution = .equalSpacing
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleStackView)
        
        view.addSubview(placeholderLabel)
        placeholderLabel.isUserInteractionEnabled = true
        addGestureToPlaceholder()
        
        view.backgroundColor = .specialColors.background
        
        view.addSubview(tableView)
        
        view.addSubview(statusBarGradientView)
        
//        view.addSubview(mainLabel)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        settingsButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        view.addSubview(addButton)
        
        updateMenu()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
//        setupGradient()
    }
    
    @objc func showMenu(_ sender: UIButton) {
        let menu = setupSettingsMenu()
        
        sender.menu = menu
        sender.showsMenuAsPrimaryAction = true
    }
    
//    private func createSettingsMenu() {
//        let settingsMenu = setupSettingsMenu()
//        settingsButton.menu = settingsMenu
//        settingsButton.showsMenuAsPrimaryAction = true
//    }
    
    
    @objc func placeholderTapped() {
    }
    
    private func addGestureToPlaceholder() {
        let tapToAnimateAddButton = UITapGestureRecognizer(target: self, action: #selector(placeholderTapped))
        self.placeholderLabel.addGestureRecognizer(tapToAnimateAddButton)
    }
    
    private func setupAccessibility() {
        view.accessibilityLabel = NSLocalizedString("Main screen", comment: "Accessibility: main screen")
        view.accessibilityHint = NSLocalizedString("Shows your comparison lists. Use the add button to create a new comparison.", comment: "Accessibility: main screen hint")
        
        addButton.accessibilityLabel = NSLocalizedString("Create new comparison", comment: "Accessibility: add button")
        addButton.accessibilityHint = NSLocalizedString("Double tap to create a new comparison.", comment: "Accessibility: add button hint")
        
        settingsButton.accessibilityLabel = NSLocalizedString("Settings", comment: "Accessibility: settings button")
        settingsButton.accessibilityHint = NSLocalizedString("Double tap to open menu with settings and options.", comment: "Accessibility: settings button hint")
        
        mainLabel.accessibilityLabel = NSLocalizedString("Choose Right", comment: "Accessibility: app title")
        mainLabel.accessibilityTraits = .header
        
        placeholderLabel.accessibilityLabel = NSLocalizedString("Tap the button below to create your first comparison", comment: "Accessibility: placeholder")
        placeholderLabel.accessibilityHint = NSLocalizedString("Double tap the add button to get started.", comment: "Accessibility: placeholder hint")
    }
    
    private func setDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    //MARK: - Gradient top edge for table view
    
    private func setupGradient(){
        
        let topOpaqueView: UIView = {
            let view = UIView()
            view.backgroundColor = .specialColors.background
            return view
        }()
        
        statusBarGradientView.addSubview(topOpaqueView)
        topOpaqueView.frame = CGRect(
            x: 0,
            y: 0,
            width: Int(view.frame.width),
            height: Int(statusBarGradientView.bounds.height) / 4 * 3)
        
        topGradientLayer.frame = statusBarGradientView.bounds
        topGradientLayer.frame = CGRect(
            x: 0,
            y: Int(topOpaqueView.bounds.height),
            width: Int(view.frame.width),
            height: Int(statusBarGradientView.bounds.height) / 4)
        
        statusBarGradientView.layer.addSublayer(topGradientLayer)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.topGradientLayer.colors = [
                UIColor.specialColors.background!.withAlphaComponent(1.0).cgColor,
                UIColor.specialColors.background!.withAlphaComponent(0.0).cgColor]
        }
    }
    
    
    //MARK: - AddButtonTransitionAnimation
    
    @objc private func addButtonTapped() {
        showNormalCreateAlert()
    }
    
    private func showNormalCreateAlert() {
        alertConfigurationForCreate()
        
        present(createNewComparisonListAlert ?? UIAlertController(), animated: true) { [weak self] in
            guard let self = self else { return }
            
            dismissGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(dismissCreateAlertGesture))
            
            self.createNewComparisonListAlert?.view.window?.isUserInteractionEnabled = true
            
            self.createNewComparisonListAlert?.view.superview?.subviews[0].addGestureRecognizer(dismissGesture)
        }
    }
        
            @objc func dismissCreateAlertGesture() {
                createNewComparisonListAlert?.dismiss(animated: true)
                createNewComparisonListAlert = UIAlertController()
        
            }
    
}


//MARK: - Set constraints

extension MainViewController {
    private func setConstraints() {
        // Отступ по гайдам iOS 26: заголовок ниже от safe area (доп. верхний отступ)
        let titleTopConstant: CGFloat = {
            if #available(iOS 26.0, *) { return 44 } // iOS 26 HIG — больший отступ для заголовка
            return 28
        }()
        titleStackTopAnchor = titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: titleTopConstant)
        
        tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 20)
        
        // Adaptive sizing - same padding for all devices
        let horizontalPadding: CGFloat = 15
        
        NSLayoutConstraint.activate([
            
            titleStackTopAnchor!,
            titleStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: horizontalPadding),
            titleStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -horizontalPadding),
            titleStackView.heightAnchor.constraint(equalToConstant: 36),
            
            settingsButton.widthAnchor.constraint(equalTo: settingsButton.heightAnchor),
            
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            addButton.heightAnchor.constraint(equalToConstant: 64),
            addButton.widthAnchor.constraint(equalToConstant: 64),
            
            tableViewTopAnchor!,
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: horizontalPadding),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -horizontalPadding),
//            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            placeholderLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            placeholderLabel.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -40),
            
            statusBarGradientView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            statusBarGradientView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarGradientView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
}


//MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        86
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let comparisonModel = comparisonsArray[indexPath.section]
        cellTapped(comparison: comparisonModel)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: "context" as NSCopying, previewProvider: nil) { _ in
            self.setupCellMenu(indexPath: indexPath)
            return self.cellMenu
        }
    }
    
//
}



//create item

extension MainViewController {

}
//MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowsHardCode
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let comparisonsCount = comparisonsArray.count
        tableViewSectionsCount = comparisonsCount
        
        switch tableViewSectionsCount {
        case 0 :
            
            UIView.animate(withDuration: 0.5, animations: {
                self.placeholderLabel.alpha = 0.6
            })
            
        case 1...:

                self.placeholderLabel.alpha = 0

        default:

                self.placeholderLabel.alpha = 0

            }
        return comparisonsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.idMainTableViewCell, for: indexPath) as? MainTableViewCell else {
            return UITableViewCell()
        }
        
        let comparisonModel = comparisonsArray[indexPath.section]
        
        cell.configureCell(model: comparisonModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        5
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        1
    }
    
}

//MARK: - Context menu for TableViewCell
extension MainViewController {
    
    @objc func dismissChangeNameAlert() {
        self.createNameChangingAlert?.dismiss(animated: true)
        self.createNameChangingAlert?.view.window?.removeGestureRecognizer(dismissGesture)
    }
    
    func setupCellMenu(indexPath: IndexPath) {
        
        let changingComparison = self.comparisonsArray[indexPath.section]
        let menuTitle = changingComparison.unwrappedName

        
        let changeName = UIAction(title: NSLocalizedString("Change name", comment: ""), image: UIImage(systemName: "pencil")) {[self] _ in
//            let changingComparison = self.comparisonsArray[indexPath.section]
            self.alertConfigurationForChangeName(comparison: changingComparison)
            present(self.createNameChangingAlert ?? UIAlertController(), animated: true) { [weak self] in
                guard let self = self else { return }
                
                dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissChangeNameAlert))
                
                self.createNameChangingAlert?.view.window?.isUserInteractionEnabled = true
                
                self.createNameChangingAlert?.view.superview?.subviews[0].addGestureRecognizer(dismissGesture)
            }
        }
        
        let changeColor = UIAction(title: NSLocalizedString("Change color", comment: ""), image: UIImage(systemName: "paintpalette")) { [weak self] _ in
            guard let self = self else { return }
            self.showColorPicker(for: changingComparison, at: indexPath)
        }

        let delete = UIAction(title: NSLocalizedString("Delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { [self] _ in
            let deleteModel = self.comparisonsArray[indexPath.section]
            let index = indexPath.section
            
            self.alertConfigurationForDeleteConfirmation(comparison: deleteModel, index: index)
            present(deleteComparisonConfirmationAlert ?? UIAlertController(), animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                self.deleteComparisonConfirmationAlert?.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
            
        }
        
        cellMenu = UIMenu(
            title: menuTitle,
            image: UIImage(systemName: "peacesign"),
            children: [changeName, changeColor, delete])
    }
    
    @objc func dismissAlertController() {
        self.dismiss(animated: true)
    }
    
    func showColorPicker(for comparison: ComparisonEntity, at indexPath: IndexPath) {
        let colorPicker = ColorPickerViewController(
            selectedColor: comparison.color,
            onColorSelected: { [weak self] colorName in
                guard let self = self else { return }
                self.sharedDataBase.updateComparisonColor(for: comparison, color: colorName)
                self.tableView.reloadData()
            }
        )
        
        if let sheet = colorPicker.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return UIScreen.main.bounds.height / 3
            }]
            sheet.prefersGrabberVisible = true
        }
        
        colorPicker.modalPresentationStyle = .pageSheet
        present(colorPicker, animated: true)
    }
}



//MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableViewActive = scrollView == tableView
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         
            let yOffset = tableView.contentOffset.y
            let shouldSnap = yOffset > 5
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0) {
                    
                    switch self.tableView.numberOfSections {
                    case 0 : self.mainLabel.alpha = 1
                        self.titleStackTopAnchor?.constant = 10
                        
                        
                    case 1... : self.mainLabel.alpha = shouldSnap ? 0 : 1
                        self.titleStackTopAnchor?.constant = shouldSnap ? -50 : 10
                        
                    default: self.mainLabel.alpha = shouldSnap ? 0 : 1
                        self.titleStackTopAnchor?.constant = shouldSnap ? -50 : 10

                    }
                    self.view.layoutIfNeeded()
                }
    }
}
 
//MARK: - Working with data

extension MainViewController {
    func getData(){
        comparisonsArray = sharedDataBase.fetchAllComparisons()
        comparisonsArray.sort { $0.unwrappedDate > $1.unwrappedDate }
        tableViewSectionsCount = comparisonsArray.count//tableView.numberOfSections
        tableView.reloadData()
    }
    
    func deleteComparisonFromTable(comparison: ComparisonEntity, index: Int) {
        
        sharedDataBase.deleteComparison(comparison: comparison)
        comparisonsArray.remove(at: index)
        setComparisonsArray(ComparisonEntities: comparisonsArray)
        tableView.reloadData()
    }
    
    public func setComparisonsArray(ComparisonEntities: [ComparisonEntity]) {
        if ComparisonEntities.isEmpty { return }
        else {
            comparisonsArray = ComparisonEntities.sorted { $0.unwrappedDate > $1.unwrappedDate }
        }
    }
}


//MARK: - Set bottomInset for tableView

extension MainViewController {
    private func setBottomInset() {
        bottomInset = 0
        insets.bottom = 0
        tableView.contentInset = insets
    }
}


//MARK: - ComparisonTableViewCellTapped
extension MainViewController {
    private func cellTapped(comparison: ComparisonEntity) {
        let destination = ComparisonListViewController()
        destination.setComparisonEntity(comparison: comparison)
        navigationController?.pushViewController(destination, animation: true, completion: {
        })
    }
}
//extension MainViewController {
//}

//MARK: - MainVC -> ObjDetailsVC creating new item -> ComparisonListVC
extension MainViewController: ObjectDetailsVCProtocol {
    func creatingIsComplete(comparisonEntity: ComparisonEntity) {

        let destination = ComparisonListViewController()
        destination.modalPresentationStyle = .fullScreen
        destination.modalPresentationStyle = .fullScreen
        destination.transitioningDelegate = self
        destination.setComparisonEntity(comparison: comparisonEntity)
        
        navigationController?.pushViewController(destination, animated: true)
        //        }
    }
    
    // MARK: - UIDocumentPickerDelegate (for testing file import)
    #if DEBUG
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        // Start accessing security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            let alert = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("Cannot access file", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            present(alert, animated: true)
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // Import comparison
        let result = ComparisonSharingService.importComparison(from: url)
        
        switch result {
        case .success:
            // Refresh data
            getData()
            
            // Show success alert with checkmark
            showImportSuccessAlert()
            
        case .failed(let error):
            var alertTitle = "Error"
            var alertMessage = "Failed to import comparison"
            var showSubscription = false
            
            switch error {
            case .limitExceeded:
                alertTitle = "Limit Exceeded"
                alertMessage = "You have reached the free limit of 1 comparison. Please upgrade to Premium to import more comparisons."
                showSubscription = true
            case .invalidFile:
                alertMessage = "Could not import the comparison file. Please make sure the file is valid."
            case .saveError:
                alertMessage = "Could not save the comparison. Please try again."
            }
            
            let alert = UIAlertController(
                title: alertTitle,
                message: alertMessage,
                preferredStyle: .alert
            )
            
            if showSubscription {
                alert.addAction(UIAlertAction(title: NSLocalizedString("Upgrade", comment: ""), style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    let subscriptionVC = SubscriptionViewController()
                    subscriptionVC.modalPresentationStyle = .pageSheet
                    if let sheet = subscriptionVC.sheetPresentationController {
                        sheet.detents = [.large()]
                        sheet.prefersGrabberVisible = true
                    }
                    self.present(subscriptionVC, animated: true)
                })
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            } else {
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            }
            
            present(alert, animated: true)
        }
    }
    #endif
}

