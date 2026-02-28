//
//  ComparisonListViewControllerNew.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 25.03.2024.
//

import Foundation
import UIKit
import CoreData

class ComparisonListViewController: UIViewController  {
    
    weak var weakTableViewDelegate: UITableViewDelegate?
    weak var weakTableViewDataSource: UITableViewDataSource?
    weak var weakCollectionViewDelegate: UICollectionViewDelegate?
    weak var weakCollectionViewDataSource: UICollectionViewDataSource?
    
    var dismissAttributeChangeNameAlertGesture = UITapGestureRecognizer()
    
    var attributeChangeNameAlert:
    UIAlertController? = UIAlertController(
        title: NSLocalizedString("Edit attribute", comment: ""),
        message: "",
        preferredStyle: .alert)
    
    var deleteItemAlert: 
    UIAlertController? = UIAlertController(
        title: NSLocalizedString("Delete", comment: ""),
        message: "",
        preferredStyle: .alert)
    
    var longPress = UILongPressGestureRecognizer()
    
    var percentSortingTap = 0
    
    var currentSortKey = itemSortKeys().value
    
    weak var saveAttributeButtonInAlertChanged: UIAlertAction?
    private var addAttributeAlert = UIAlertController()
    
    var tableViewWidthFixed = false
    
    var tableCompressed = false
    
    private var previousContentOffsetX: CGFloat = 0
    
    var minConstraintConst: CGFloat = 109
    var maxConstraintConstant: CGFloat = 265
    var animatedConstraint: NSLayoutConstraint?
    
    var comparisonItemsFetchResultsController: NSFetchedResultsController<ComparisonItemEntity>!
    var comparisonAttributesFetchResultsController: NSFetchedResultsController<ComparisonAttributeEntity>!
    var comparisonValuesFetchResultsController: NSFetchedResultsController<ComparisonValueEntity>!
    
    weak var comparisonItemsFetchResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    weak var comparisonAttributesFetchResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    weak var comparisonValuesFetchResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    
    let sharedData = CoreDataManager.shared
    var comparisonEntity = ComparisonEntity()
    
    let notchView = UIView()
    var settingsMenu = UIMenu()
    
    var attributeCellMenu = UIMenu()
    var objectCellMenu = UIMenu()
    
    // Track pending changes for batch updates
    var pendingAttributeChanges: [(type: NSFetchedResultsChangeType, indexPath: IndexPath?, newIndexPath: IndexPath?)] = []
    
    private let bottomInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    var customLayout = ValuesCollectionViewLayout()
    
    var attributesCollectionViewLeadingAnchor: NSLayoutConstraint?
    
    let attributesCellHeight: CGFloat = 45
    
    public let itemTabeFooterHeight = CGFloat(5)
    
    public let valuesCollectionCellHeight = CGFloat(91)
    public let valuesCollectionCellWidth = CGFloat(86)
    
    let objectTableView = ObjectTableView()
    let attributesCollectionView = AttributesCollectionView()
    let valuesCollectionView = ValuesColectionView()
    
    var objectTableIsActive = false
    private var attributesCollectionIsActive = false
    
    var isUserDrivenReordering = false
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString(string: "Choose Right",
                                                         attributes:
                                                            [NSAttributedString.Key.kern: -1.37])
        label.font = .sfProTextBold33()
        label.textColor = UIColor(named: "specialText")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        //        label.adjustsFontSizeToFitWidth = true
        //        label.minimumScaleFactor = 0.5
        //        label.numberOfLines = 2
        
        return label
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(named: "specialText")
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(named: "specialText")
        let image = UIImage(systemName: "ellipsis")
        button.setImage((image), for: .normal)
        
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        // Fix button size to prevent jumping when menu closes
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
        return button
    }()
    
    private let addAttributeButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.contentHorizontalAlignment = .right
        
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
        button.configuration = configuration
        
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .sfProTextRegular14()
        button.setTitleColor(.specialColors.detailsOptionTableText?.withAlphaComponent(CGFloat(0.6)), for: .normal)
        button.backgroundColor = .specialColors.background
//        button.alpha = 0.6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var titleStackView = UIStackView()
    
    private lazy var addButton = AddButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        valuesCollectionView.collectionViewLayout = customLayout
        
        setupView()
        setDelegates()
        setConstraints()
        
        loadSavedData(itemsSortKey: currentSortKey)
        

    }
    
    
//    //MARK: - ?????????????????
//    deinit {
//        comparisonItemsFetchResultsController.delegate = nil
//        comparisonValuesFetchResultsController.delegate = nil
//        comparisonAttributesFetchResultsController.delegate = nil
//                
//        attributesCollectionView.delegate = nil
//        attributesCollectionView.dataSource = nil
//        
//        
//    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ScreenOrientationUtility.lockOrientation(.all)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
        
        ScreenOrientationUtility.lockOrientation(.portrait)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        ScreenOrientationUtility.lockOrientation(.portrait)
//    }
    
    private func setupView() {
        
        view.backgroundColor = UIColor.specialColors.background
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        titleStackView = UIStackView(arrangedSubviews: [
            backButton,
            mainLabel,
            settingsButton],
                                     axis: .horizontal,
                                     spacing: 20)
        titleStackView.distribution = .equalSpacing
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        // Prevent layout updates that cause button jumping
        titleStackView.layoutMargins = .zero
        titleStackView.isLayoutMarginsRelativeArrangement = false
        view.addSubview(titleStackView)
        
        view.addSubview(attributesCollectionView)
        view.addSubview(valuesCollectionView)
        view.addSubview(objectTableView)
        
        attributesCollectionView.backgroundColor = .specialColors.background
        
        objectTableView.contentInset = bottomInsets
        objectTableView.contentInsetAdjustmentBehavior = .never
        
        valuesCollectionView.contentInset = bottomInsets
        valuesCollectionView.contentInsetAdjustmentBehavior = .never
        
        addAttributeButton.addTarget(self, action: #selector(addAttributeTapped), for: .touchUpInside)
        view.addSubview(addAttributeButton)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        view.addSubview(addButton)
        
        // Setup menu with standard animation
        settingsButton.menu = setupSettingsMenu()
        settingsButton.showsMenuAsPrimaryAction = true
        
//        addLongPress()
        
    }
    
    private func setDelegates() {
        
        weakTableViewDelegate = self
        weakTableViewDataSource = self
        weakCollectionViewDelegate = self
        weakCollectionViewDataSource = self
        
        
        objectTableView.delegate = weakTableViewDelegate
        objectTableView.dataSource = weakTableViewDataSource
        objectTableView.register(ObjectTableViewCell.self, forCellReuseIdentifier: ObjectTableViewCell.idTableViewCell)
        
        attributesCollectionView.delegate = weakCollectionViewDelegate
        attributesCollectionView.dataSource = weakCollectionViewDataSource
        attributesCollectionView.register(AttributesCollectionViewCell.self, forCellWithReuseIdentifier: AttributesCollectionViewCell.idAttributesCollectionViewCell)
        
        // Drag & Drop
        attributesCollectionView.dragInteractionEnabled = true
        attributesCollectionView.dragDelegate = self
        attributesCollectionView.dropDelegate = self
        
        valuesCollectionView.delegate = weakCollectionViewDelegate
        valuesCollectionView.dataSource = weakCollectionViewDataSource
        valuesCollectionView.register(ValuesCollectionViewCell.self, forCellWithReuseIdentifier: ValuesCollectionViewCell.idValuesColectionViewCell)
        
        
        
    }
    

    
    @objc private func backButtonTapped() {
        
        ScreenOrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            self.navigationController?.popViewController(animated: true)
            
            if let presentedController = self.navigationController?.presentedViewController {
                presentedController.dismiss(animated: true) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.navigationController?.popToRootViewController(animated: true)

            }
            
        }
    }
    
    public func toggleWobbleAnimation(){
        
    }
    
    func openDetailsForNewComparison() {
        addButtonTapped()
    }
    
}

//MARK: - SetConstraints
extension ComparisonListViewController {
    private func setConstraints() {
        
        attributesCollectionViewLeadingAnchor = attributesCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: maxConstraintConstant)
        
        // Adaptive sizing for iPad - Removed max width limitation
        let horizontalPadding: CGFloat = 15 // Always use 15 padding regardless of device
        
        NSLayoutConstraint.activate([
            
            backButton.heightAnchor.constraint(equalToConstant: 33),
            backButton.widthAnchor.constraint(equalToConstant: 33),
            
            titleStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: horizontalPadding),
            titleStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -horizontalPadding),
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleStackView.heightAnchor.constraint(equalToConstant: 40),
            
            attributesCollectionViewLeadingAnchor!,
            attributesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            attributesCollectionView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 10),
            attributesCollectionView.heightAnchor.constraint(equalToConstant: 45),
            
            valuesCollectionView.topAnchor.constraint(equalTo: attributesCollectionView.bottomAnchor, constant: 0),
            valuesCollectionView.leadingAnchor.constraint(equalTo: attributesCollectionView.leadingAnchor),
            valuesCollectionView.trailingAnchor.constraint(equalTo: attributesCollectionView.trailingAnchor),
            valuesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            objectTableView.topAnchor.constraint(equalTo: valuesCollectionView.topAnchor),
            objectTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: horizontalPadding),
            objectTableView.bottomAnchor.constraint(equalTo: valuesCollectionView.bottomAnchor),
            objectTableView.trailingAnchor.constraint(equalTo: attributesCollectionView.leadingAnchor, constant: 0),
            
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -max(24, horizontalPadding)),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24),
            addButton.heightAnchor.constraint(equalToConstant: 64),
            addButton.widthAnchor.constraint(equalToConstant: 64),
            
            addAttributeButton.bottomAnchor.constraint(equalTo: objectTableView.topAnchor),
            addAttributeButton.trailingAnchor.constraint(equalTo: objectTableView.trailingAnchor),
            addAttributeButton.heightAnchor.constraint(equalToConstant: attributesCellHeight),
            addAttributeButton.widthAnchor.constraint(equalToConstant: valuesCollectionCellWidth)
        ]
        )
    }
}


//MARK: - TableView DataSource & Delegate
extension ComparisonListViewController: UITableViewDataSource {
    
//MARK: DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = comparisonItemsFetchResultsController.fetchedObjects?.count else { return 0 }
            return sections
        }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let comparison = comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] else { return UITableViewCell()}
        
        guard let cell = objectTableView.dequeueReusableCell(withIdentifier: ObjectTableViewCell.idTableViewCell, for: indexPath) as? ObjectTableViewCell
        else {
           return UITableViewCell()
        }
        cell.configureCell(comparisonItemEntity: comparison)
//        cell.cellCollapseDelegate = self
        
        let weakCellDelegate = self
        cell.objectTableViewCellDelegate = weakCellDelegate
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        itemTabeFooterHeight
    }

}

//MARK: - TableView Delegate

extension ComparisonListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        valuesCollectionCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section]
        itemCellTapped(comparisonItem: item ?? ComparisonItemEntity())
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            
            self.setupObjectCellMenu(indexPath: indexPath)
            
            return self.objectCellMenu
        }
    }
    
    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        objectTableView.clipsToBounds = false
        return makeCellPreview(for: configuration)
    }
    
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        objectTableView.clipsToBounds = true
        return makeCellPreview(for: configuration)
    }
    

}

//MARK: - CollectionView DataSource

extension ComparisonListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let items = comparisonAttributesFetchResultsController.fetchedObjects?.count ?? 0
        
        return items
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var sections = 1
        
        switch collectionView {
        case valuesCollectionView:
//            sections = comparisonItemsFetchResultsController.fetchedObjects?.count ?? 0
            sections = comparisonItemsFetchResultsController.fetchedObjects?.count ?? 0
        case attributesCollectionView:
            sections = 1
        default :
            sections = 1
        }
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var returnedCell = UICollectionViewCell()
        
        switch collectionView {
        case attributesCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttributesCollectionViewCell.idAttributesCollectionViewCell, for: indexPath) as? AttributesCollectionViewCell else {
                return UICollectionViewCell()
            }
            let attribute = comparisonAttributesFetchResultsController.fetchedObjects![indexPath.row]
            cell.attributeLabel.text = attribute.unwrappedName
            cell.index = indexPath
            cell.isUserInteractionEnabled = true
            cell.backgroundColor = .specialColors.background
            
            let interaction = UIContextMenuInteraction(delegate: self)
            cell.addInteraction(interaction)
            
            returnedCell = cell
        
        case valuesCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ValuesCollectionViewCell.idValuesColectionViewCell, for: indexPath) as? ValuesCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let item = comparisonItemsFetchResultsController.fetchedObjects![indexPath.section]
            let attribute = comparisonAttributesFetchResultsController.fetchedObjects![indexPath.row]
            
            let cellValue = sharedData.fetchValue(item: item, attribute: attribute)
            cell.delegate = self
            
            cell.updateButtonTitle(isValueTrue: cellValue.booleanValue)
            
            returnedCell = cell
        default:
            return returnedCell
        }
        
        return returnedCell
    }
    
    
}

//MARK: - CollectionViewDelegate
extension ComparisonListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle item selection if needed
    }
    
}

//MARK: - cellsDelegates

extension ComparisonListViewController: valuesCollectionViewCellDelegate {
    func didTapValueButton(cell: ValuesCollectionViewCell) {
        if let indexPath = valuesCollectionView.indexPath(for: cell) {
            let item = comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] ?? ComparisonItemEntity()
            
            let attribute = comparisonAttributesFetchResultsController.fetchedObjects?[indexPath.row] ?? ComparisonAttributeEntity()
            
            let value = sharedData.fetchValue(item: item, attribute: attribute)
            sharedData.changeBooleanValue(for: value)
            
            
            refreshCellWhenValueChanges(indexPath: indexPath, item: item)
            
            UIView.animate(withDuration: 0.3) {
                self.valuesCollectionView.reloadItems(at: [indexPath])
            }

        }
    }
    
    func refreshCellWhenValueChanges(indexPath: IndexPath, item: ComparisonItemEntity) {
                let relatedObjectTableViewCell = objectTableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? ObjectTableViewCell
                relatedObjectTableViewCell?.valueChangedRefresh(comparisonItemEntity: item)
    }
}

//MARK: - ScrollView
extension ComparisonListViewController: UIScrollViewDelegate {
    
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        objectTableIsActive = scrollView == objectTableView
        attributesCollectionIsActive = scrollView == attributesCollectionView
        
        if (attributesCollectionViewLeadingAnchor?.constant == minConstraintConst && scrollView.contentOffset.x > 10) || isEditing {
            tableViewWidthFixed = true
        } else {
            tableViewWidthFixed = false
        }
        
    }
    
    private func scrollViewSync(scrollView: UIScrollView) {
        if objectTableIsActive && scrollView == objectTableView {
            let yOffset = objectTableView.contentOffset.y
            valuesCollectionView.contentOffset.y = yOffset
        }
        
        if attributesCollectionIsActive && scrollView == attributesCollectionView {
            let xOffset = attributesCollectionView.contentOffset.x
            valuesCollectionView.contentOffset.x = xOffset
            
        }
        
        if !attributesCollectionIsActive && !objectTableIsActive && scrollView == valuesCollectionView {
            let xOffset = valuesCollectionView.contentOffset.x
            let yOffset = valuesCollectionView.contentOffset.y
            
            attributesCollectionView.contentOffset.x = xOffset
            objectTableView.contentOffset.y = yOffset
        }
    }
    
    private func sizingViewWithScroll(scrollView: UIScrollView){
        let leftMovementResizingPoint = maxConstraintConstant - 30
        let rightMovementResizingPoint = minConstraintConst + 30
        
        
        if attributesCollectionViewLeadingAnchor?.constant == minConstraintConst {
            tableCompressed = true
        }
        if attributesCollectionViewLeadingAnchor?.constant == maxConstraintConstant {
            tableCompressed = false
        }
        
        if attributesCollectionViewLeadingAnchor?.constant ?? minConstraintConst > rightMovementResizingPoint && tableCompressed == true {
            
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0) {
                    self.attributesCollectionViewLeadingAnchor?.constant = self.maxConstraintConstant
                    self.tableCompressed = false
                    self.view.layoutIfNeeded()
                }
        } else if tableCompressed == true {
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0) {
                    self.attributesCollectionViewLeadingAnchor?.constant = self.minConstraintConst
                    self.tableCompressed = true
                    self.view.layoutIfNeeded()
                }
        }
        
        if attributesCollectionViewLeadingAnchor?.constant ?? maxConstraintConstant < leftMovementResizingPoint && tableCompressed == false {
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0) {
                    self.attributesCollectionViewLeadingAnchor?.constant = self.minConstraintConst
                    self.tableCompressed = true
                    self.view.layoutIfNeeded()
                }
        } else if tableCompressed == false {
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.2,
                delay: 0) {
                    self.attributesCollectionViewLeadingAnchor?.constant = self.maxConstraintConstant
                    self.tableCompressed = false
                    self.view.layoutIfNeeded()
                }
        }
        
    }
    
    func tableViewSyncWithScroll(scrollView: UIScrollView) {
        
        let currentOffsetX = scrollView.contentOffset.x
        let scrollDiff = currentOffsetX - previousContentOffsetX
        
        let bounceBorderContentOffsetX = -scrollView.contentInset.left
        
        let contentMovesLeft = scrollDiff > 0 && currentOffsetX > bounceBorderContentOffsetX
        let contentMovesRight = scrollDiff < 0 && currentOffsetX < bounceBorderContentOffsetX
        
        let currentTopViewLeadingAnchorConst = attributesCollectionViewLeadingAnchor!.constant
        var newTopViewLeadingAnchorConst = currentTopViewLeadingAnchorConst
        
        
        if contentMovesLeft {
            newTopViewLeadingAnchorConst = max(currentTopViewLeadingAnchorConst - scrollDiff, minConstraintConst)
            
        } else if contentMovesRight && !tableViewWidthFixed {
            newTopViewLeadingAnchorConst = min(currentTopViewLeadingAnchorConst - scrollDiff, maxConstraintConstant)
        }
        
        if newTopViewLeadingAnchorConst != currentTopViewLeadingAnchorConst {
            attributesCollectionViewLeadingAnchor?.constant = newTopViewLeadingAnchorConst
            scrollView.contentOffset.x = previousContentOffsetX
        }
        
        attributesCollectionViewLeadingAnchor?.constant = newTopViewLeadingAnchorConst
        previousContentOffsetX = scrollView.contentOffset.x
    
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewSync(scrollView: scrollView)
        tableViewSyncWithScroll(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        sizingViewWithScroll(scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sizingViewWithScroll(scrollView: scrollView)
    }
}


//MARK: - setComparisonEntity

extension ComparisonListViewController {
    
    public func setComparisonEntity(comparison: ComparisonEntity) {
        comparisonEntity = comparison
        
        
        loadSavedData(itemsSortKey: currentSortKey)
        
        // Set label to comparison name
        mainLabel.text = comparisonEntity.unwrappedName
        
        customLayout = ValuesCollectionViewLayout(
            cellWidth: valuesCollectionCellWidth,
            cellHeight: valuesCollectionCellHeight + itemTabeFooterHeight)
        
        valuesCollectionView.collectionViewLayout = customLayout
    }
}


//MARK: - Buttons & Taps
extension ComparisonListViewController: UIViewControllerTransitioningDelegate {
    
    public func reloadTables() {
        self.valuesCollectionView.reloadData()
        self.attributesCollectionView.reloadData()
        self.objectTableView.reloadData()
    }
    
    @objc private func addButtonTapped() {
        
        let objectDetailsViewController = ObjectDetailsViewController()
        objectDetailsViewController.transitioningDelegate = self
        objectDetailsViewController.modalPresentationStyle = .overCurrentContext
        
        objectDetailsViewController.setForNewItem(comparisonID: comparisonEntity.id?.uuidString ?? "", needUpdateViewController: true)
        
        objectDetailsViewController.detailsClosingCompletion = { flag in
            if flag {
                self.reloadTables()
            }
        }
        
        ScreenOrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.present(objectDetailsViewController, animated: true)
        }
            
    }
    
    @objc private func addAttributeTapped() {
        
        alertNewAttributeConfiguration()
        present(addAttributeAlert, animated: true) {
            [weak self] in
            guard let self = self else { return }
            
            let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAddAttributeAlertGesture))
            
            self.addAttributeAlert.view.window?.isUserInteractionEnabled = true
            
            self.addAttributeAlert.view.superview?.subviews[0].addGestureRecognizer(dismissGesture)
        }
    }
    
    @objc func dismissAddAttributeAlertGesture() {
        addAttributeAlert.dismiss(animated: true)
    }
    
    private func itemCellTapped(comparisonItem: ComparisonItemEntity) {
        let objectDetailsViewController = ObjectDetailsViewController()
        
        weak var transitionDelegate: UIViewControllerTransitioningDelegate?
        transitionDelegate = self
        
        objectDetailsViewController.transitioningDelegate = transitionDelegate
        objectDetailsViewController.modalPresentationStyle = .overCurrentContext
        objectDetailsViewController.setForExistingItem(comparisonItem: comparisonItem)
        
        objectDetailsViewController.detailsClosingCompletion = { flag in
            if flag {
                self.reloadTables()
            }
        }
        
        ScreenOrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.present(objectDetailsViewController, animated: true)
        }



    }
}


//MARK: - ObjectTableViewCellProtocol (passing table state into the cells)
extension ComparisonListViewController: ObjectTableViewCellProtocol {
    func refreshCellWhenValueChanges() {
    }
    
    func isCellCollapsedNow() -> Bool {
        let report = self.objectTableView.frame.width > 150 ? false : true
        return report
    }
}


//MARK: New Attribute Allert Config

extension ComparisonListViewController: UITextFieldDelegate {
    private func alertNewAttributeConfiguration() {
        
        self.addAttributeAlert = UIAlertController(title: NSLocalizedString("New attribute", comment: ""), message: "", preferredStyle: .alert)
        
        addAttributeAlert.addTextField { alertTextfield in
            alertTextfield.delegate = self
            alertTextfield.autocapitalizationType = .sentences
            alertTextfield.clearButtonMode = .always
            alertTextfield.addTarget(self, action: #selector(self.textfieldChanged), for: .editingChanged)
            
            alertTextfield.translatesAutoresizingMaskIntoConstraints = false
            
        }
        
        let saveButton = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { [weak self, weak addAttributeAlert] (_) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let textfieldText = addAttributeAlert?.textFields?[0].text ?? "No text"
                
                self.sharedData.createComparisonAttribute(name: textfieldText, relatedComparison: self.comparisonEntity)
            }
        }
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action in
            self.addAttributeAlert.dismiss(animated: true)
            self.addAttributeAlert = UIAlertController()
            self.addAttributeAlert.view.superview?.subviews[0].isUserInteractionEnabled = true

        }
        
        addAttributeAlert.addAction(cancelButton)
        addAttributeAlert.addAction(saveButton)
        saveAttributeButtonInAlertChanged = saveButton
        saveButton.isEnabled = false
        
        
    }
    
    @objc func textfieldChanged(_ sender: Any) {
        let textfield = sender as! UITextField
        guard let textfieldText = textfield.text else { return }
        
        let attrsNames: [String] = comparisonAttributesFetchResultsController.fetchedObjects?.map { $0.unwrappedName } ?? []
        
        self.saveAttributeButtonInAlertChanged?.isEnabled = !textfieldText.trimmingCharacters(in: .whitespaces).isEmpty && !attrsNames.contains(textfieldText)
    }
    
    @objc func dismissAlert() {
        addAttributeAlert.dismiss(animated: true)
        addAttributeAlert = UIAlertController()
        view.subviews.last?.removeFromSuperview()
    }
    
    
}


//  Sort methods
extension ComparisonListViewController {
    
    func updateSortKey(_ sortKey: String) {
        currentSortKey = sortKey
        
        self.comparisonEntity.itemsArray.forEach { $0.updateTrueValuesCount() }

        self.itemsFetchController(sortKey: sortKey)
//        loadSavedData(itemsSortKey: sortKey)
//        objectTableView.reloadData()
//        valuesCollectionView.reloadData()
        // Update menu (showsMenuAsPrimaryAction is already set in setupView)
        settingsButton.menu = setupSettingsMenu()
        
        self.objectTableView.reloadData()
        
        
    }
    
}

// MARK: - Drag & Drop Attributes
extension ComparisonListViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard collectionView == attributesCollectionView else { return [] }
        
        // Получаем атрибут из контроллера
        guard let attribute = comparisonAttributesFetchResultsController.fetchedObjects?[indexPath.item] else { return [] }
        
        let itemProvider = NSItemProvider(object: attribute.objectID.uriRepresentation().absoluteString as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = attribute // Локальный объект для передачи внутри приложения
        return [dragItem]
    }
}

extension ComparisonListViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        if collectionView == attributesCollectionView && collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        // Получаем sourceIndexPath (предполагаем один элемент)
        guard let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath,
              let attribute = item.dragItem.localObject as? ComparisonAttributeEntity else { return }
        
        // Обновляем порядок в Core Data
        // Важно: destinationIndexPath может быть за пределами текущего количества элементов, если перетаскиваем в конец
        // Но так как мы перетаскиваем внутри одной секции и одного collection view, source и destination всегда валидны
        
        // Выполняем обновление в batch updates, чтобы анимация была плавной
        collectionView.performBatchUpdates {
            // Удаляем и вставляем элемент в collection view
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
            
            // Обновляем порядок в Core Data
            // Обратите внимание: метод updateComparisonAttributeOrder должен корректно обрабатывать индексы
            // В Core Data мы сортируем по дате (descending), поэтому первый элемент в UI (index 0) имеет самую позднюю дату
            // Устанавливаем флаг, чтобы FRC не обновлял UI во время ручного перемещения
            self.isUserDrivenReordering = true
            sharedData.updateComparisonAttributeOrder(attribute: attribute, sourceIndex: sourceIndexPath.item, destinationIndex: destinationIndexPath.item)
            
        } completion: { _ in
            // После завершения анимации перемещения атрибута, обновляем значения
            // Так как порядок атрибутов изменился, ячейки значений тоже должны обновиться
            self.isUserDrivenReordering = false
            self.valuesCollectionView.reloadData()
        }
    }
}
