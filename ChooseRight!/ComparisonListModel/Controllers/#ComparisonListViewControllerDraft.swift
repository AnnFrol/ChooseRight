////
////  MainViewController.swift
////  ChooseRight!
////
////  Created by Александр Фрольцов on 01.04.2023.
////
//
//import UIKit
//import CoreData
//
//class ComparisonListViewController: UIViewController, CellColapsable, UIViewControllerTransitioningDelegate {
//    
//    
//    public func reloadTables() {
//        self.valuesCollectionView.reloadData()
//        self.attributesCollectionView.reloadData()
//        self.objectTableView.reloadData()
//    }
//    func isLabelShorted(viewCollapsed: Bool) -> Bool {
//        return false
//    }
//    
//    func isShorted(viewCollapsed: Bool) -> Bool {
//        if viewCollapsed {
//            print("isShorted TRUE")
//            return true
//        } else { 
//            print("isShorted FALSE")
//            return false }
//    }
//            
//    var comparisonItemsFetchResultsController: NSFetchedResultsController<ComparisonItemEntity>!
//    var comparisonAttributesFetchResultsController: NSFetchedResultsController<ComparisonAttributeEntity>!
//    var comparisonValuesFetchResultsController: NSFetchedResultsController<ComparisonValueEntity>!
//    
//    public let notchView: UILabel = {
//       let label = UILabel()
//        label.text = "    Choose Right!    "
//        label.font = .sfProDisplaySemibold12()
//        label.backgroundColor = .specialColors.threeBlueLavender
//        label.textColor = .specialColors.detailsMainLabelText
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.layer.cornerRadius = 8
//        label.clipsToBounds = true
//        label.alpha = 0
//        return label
//    }()
//    
//    var tableViewWidthFixed = false
//    var tableCompressed = false
//    
//    var shouldSnap = Bool()
//    var shouldReturnPosition = Bool()
//    
//    let shadowTop: UIView = {
//        let view = UIView()
//        view.backgroundColor = .black
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.zPosition = 1000
//        view.isUserInteractionEnabled = true
//        view.alpha = 0.3
//        view.isHidden = true
//        return view
//    }()
//    let shadowBottom: UIView = {
//        let view = UIView()
//        view.backgroundColor = .black
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.zPosition = 1000
//        view.isUserInteractionEnabled = true
//        view.alpha = 0.3
//        view.isHidden = true
//        return view
//    }()
//    
//    let wobble = CAKeyframeAnimation()
//    var attributeCellMenu = UIMenu()
//    
//    var settingsMenu = UIMenu()
//    
//    weak var saveAttributeButtonInAlertChanged: UIAlertAction?
//    
//    private var maxConstraintConstant: CGFloat = 240
//    private var midleConstraintConstant: CGFloat = 120
//    private var minConstraintConstant: CGFloat = 60
//
//    
//    private var pinnedConstraint: NSLayoutConstraint?
//    private var animatedConstraint: NSLayoutConstraint?
//    private var changeableConstraint: NSLayoutConstraint?
//    private var previousContentOffsetX: CGFloat = 0
//    
//    private var horizontalCellsCount = 0
//    private var verticalCellsCount = 0
//    
//    let sharedData = CoreDataManager.shared
//    
//    var comparisonEntity = ComparisonEntity()
//    
//    private var addNewAttributeAlert = UIAlertController()
//    
//    private let bottomInsets = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)// UIEdgeInsets.zero//
//    
//    private var customLayout = ValuesCollectionViewLayout()//UICollectionViewLayout()
//        
//    public var objectTableViewTrailingAnchor: NSLayoutConstraint?
//    public var attributesCVLeadingAnchor: NSLayoutConstraint?
//    
//    public let itemTableFooterHeight = CGFloat(5)
//    public var itemTableCellHeight = CGFloat(91) //0.11
//
//    public let attributesCVCellHeight = CGFloat(45)
//    public let valueCVCellWidth = CGFloat(86)
//    
//     let objectTableView = ObjectTableView()
//     let attributesCollectionView = AttributesCollectionView()
//     var valuesCollectionView = ValuesColectionView()
//    
//    var longPressGesture = UILongPressGestureRecognizer()
//    
//    private var objectTableActive: Bool = false
//    private var attributesCollectionActive: Bool = false
//    
//    private var tableViewIsCollapsed: Bool = false
//    
//    private var titleStackView = UIStackView()
//    
//    
//    // needs to replace to extension:
//    private let mainLabel: UILabel = {
//       let label = UILabel()
//        label.attributedText = NSMutableAttributedString(string: "Choose Right",
//                                                         attributes:
//                                                            [NSAttributedString.Key.kern: -1.37])
//        label.font = .sfProTextBold33()
//        label.textColor = UIColor(named: "specialText")
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//        
//    lazy var backButton: UIButton = {
//        let button = UIButton()
//        button.tintColor = UIColor(named: "specialText")
//        let image = UIImage(named: "backButton")?.withRenderingMode(.alwaysTemplate)
//        button.setImage((image), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    lazy var settingsButton: UIButton = {
//        let button = UIButton()
//        button.tintColor = UIColor(named: "specialText")
//        let image = UIImage(named: "optionButton")
//        button.setImage((image), for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    lazy var editingDoneButton: UIButton = {
//       let button = UIButton()
////        button.tintColor = UIColor(named: "specialText")
////        button.titleLabel?.textColor = UIColor(named: "specialText")
//        button.setTitleColor(UIColor.specialColors.text, for: .normal)
//        button.setTitle("Done", for: .normal)
//        button.titleLabel?.font = .sfProTextRegular14()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let addAttributeButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("+", for: .normal)
//        button.titleLabel?.font = .sfProTextRegular14()
//        button.tintColor = .specialColors.detailsOptionTableText
//        button.setTitleColor(.specialColors.detailsOptionTableText, for: .normal)
//        button.alpha = 0.6
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    private lazy var addButton = AddButton()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//                
//        setupViews()
//        setDelegates()
//        setConstraints()
//        alertNewAttributeConfiguration()
//        
//        self.setupSettingsMenu()
//        
//        navigationController?.interactivePopGestureRecognizer?.delegate = navigationController as? any UIGestureRecognizerDelegate
//
//        
//        print(self.navigationController?.viewControllers ?? "nil")
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        addButton.layer.cornerRadius = addButton.frame.width / 2
//        
////        longPressGesture = UILongPressGestureRecognizer(target: attributesCollectionView, action: #selector(self.attributeCellLongPressed))
//        
////        customLayout = ValuesCollectionViewLayout(
////            cellWidth: valueCVCellWidth,
////            cellHeight: itemTableCellHeight + itemTableFooterHeight )
////
////        valuesCollectionView.collectionViewLayout = customLayout
//        
//    }
//    
//    override func viewWillLayoutSubviews() {
////        UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
//        
//    }
//    
//    override func setEditing(_ editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: animated)
//        attributesCollectionView.indexPathsForVisibleItems.forEach { indexPath in
//            let cell = attributesCollectionView.cellForItem(at: indexPath) as! AttributesCollectionViewCell
//            cell.isEditing = editing
//            
//        }
//    }
//
// private func setupViews() {
//     
//     valuesCollectionView.alwaysBounceHorizontal = true
//     attributesCollectionView.alwaysBounceHorizontal = true
//     valuesCollectionView.alwaysBounceVertical = false
//                          
//     view.backgroundColor = UIColor(named: "specialBackground")
//     
//     backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
//     
//     titleStackView = UIStackView(arrangedSubviews: [ backButton,
//                                                      mainLabel,
//                                                      settingsButton],
//                                  axis: .horizontal,
//                                  spacing: 20)
//     titleStackView.distribution = .equalSpacing
//     titleStackView.translatesAutoresizingMaskIntoConstraints = false
//     view.addSubview(titleStackView)
//     
//     view.addSubview(editingDoneButton)
//     editingDoneButton.addTarget(self, action: #selector(toggleWobbleAnimation), for: .touchUpInside)
//     editingDoneButton.isHidden = true
//     
//     addAttributeButton.addTarget(self, action: #selector(addAttributeTapped), for: .touchUpInside)
//     view.addSubview(addAttributeButton)
//     
//     
//     objectTableView.contentInsetAdjustmentBehavior = .never
//     objectTableView.contentInset = bottomInsets
//     view.addSubview(objectTableView)
//     
//     
//     valuesCollectionView.contentInsetAdjustmentBehavior = .never
//     valuesCollectionView.contentInset = bottomInsets
//     view.addSubview(valuesCollectionView)
//     
//     attributesCollectionView.contentInsetAdjustmentBehavior = .never
//     view.addSubview(attributesCollectionView)
//     
//     
//     addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
//     view.addSubview(addButton)
//     
////     view.addSubview(shadowTop)
//     view.addSubview(shadowBottom)
//     
//     view.addSubview(notchView)
//     
////     addDismissGesture()
////     addBlurToShadow()
//     addGestureForShadows()
//     addLongPress()
//     
// }
//
//    
//
//    
//    
////MARK: - Did collapse
//    
////    private func addDismissGesture() {
////        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(sender:)))
////        gesture.direction = .right
////        view.addGestureRecognizer(gesture)
////    }
////
////    @objc private func swipeAction(sender: UISwipeGestureRecognizer) {
////        let location = sender.location(in: view)
////        if location.x < (view.frame.width - titleStackView.frame.width) / 2  {
////
////            dismiss(animated: true)
////        }
////    }
//    internal func didCollapse(viewCollapsed: Bool) {
//        
//        if viewCollapsed {
//            print("Collapsed")
//            tableViewIsCollapsed = true
//        } else {
//            print("Not collapsed")
//            tableViewIsCollapsed = false
//        }
//        
////        UIView.animate(withDuration: 0.3) {
////            self.objectTableView.reloadData()
////        }
//        
//        let visiblerows = objectTableView.indexPathsForVisibleRows
//        guard let startInteger = visiblerows?.first?.section else { return }
//        guard let finalInteger = visiblerows?.last?.section else {return }
//        print(visiblerows)
////        objectTableView.reloadData()
//        
//        
//        //MARK: ?? Is it necessary?
////        objectTableView.reloadSections(IndexSet(integersIn: startInteger...finalInteger), with: .fade)
//        //?? NO.
//        
//        
//        
////        objectTableView.reloadData()
////        UIView.animate(withDuration: 0.5, animations: {
////            self.objectTableView.beginUpdates()
////            self.objectTableView.reloadData()
////            self.objectTableView.endUpdates()
////        })
//        
////        UIView.animate(withDuration: 2, delay: 2, usingSpringWithDamping: 7, initialSpringVelocity: 2, options: .allowAnimatedContent) {
////            self.objectTableView.beginUpdates()
////            self.objectTableView.reloadData()
////            self.objectTableView.endUpdates()
////        }
//    }
//    
//    
////MARK: - addButtonTransitionAnimation
//    
//    @objc private func addButtonTapped() {
//        let objectDetailsViewController = ObjectDetailsViewController()
//        objectDetailsViewController.transitioningDelegate = self
//        objectDetailsViewController.modalPresentationStyle = .overCurrentContext
//        objectDetailsViewController.setForNewItem(comparisonID: comparisonEntity.id?.uuidString ?? "", needUpdateViewController: true)
//        
//        objectDetailsViewController.detailsClosingCompletion = { flag in
//            if flag {
//                self.reloadTables()
//                }
//            }
//        self.present(objectDetailsViewController, animated: true)
//        }
//    
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return AddButtonTransitionAnimation(presentationViewController: ComparisonListViewController.self, isPresenting: true)
//    }
//
//    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return AddButtonTransitionAnimation(presentationViewController: ComparisonListViewController.self, isPresenting: false)
//    }
//    
////MARK: -backButtonTapped
//    @objc private func backButtonTapped() {
//        self.notchView.alpha = 0
//        self.navigationController?.popViewController(animated: true)
//    }
//    
////MARK: - addAttributeTapped
//    
//    @objc private func addAttributeTapped() {
//        alertNewAttributeConfiguration()
//        present(addNewAttributeAlert, animated: true)
//    }
//}
//
//
////MARK: - UIScrollViewDelegate
//  
//
////        if attributesCollectionActive && scrollView == attributesCollectionView {
////
//////            let xOffset = attributesCollectionView.contentOffset.x
////            valuesCollectionView.contentOffset.x = xOffset
////
////
////            tableViewIsCollapsed = shouldSnap
////
////            didCollapse(viewCollapsed: shouldSnap)
////
//////            UIViewPropertyAnimator.runningPropertyAnimator(
//////                withDuration: 0.3,
//////                delay: 0) {
//////                    self.objectTableViewTrailingAnchor?.constant = shouldSnap ? 120 : 240
//////                }
////            print("AttributesCV xOffset:", xOffset)
////        }
////
////        if objectTableActive && scrollView == objectTableView {
////            let yOffset = objectTableView.contentOffset.y
////            valuesCollectionView.contentOffset.y = yOffset
////        }
////
////        if !objectTableActive && scrollView == valuesCollectionView {
//////            let xOffset = valuesCollectionView.contentOffset.x
////            let yOffset = valuesCollectionView.contentOffset.y
////            objectTableView.contentOffset.y = yOffset
////            attributesCollectionView.contentOffset.x = xOffset
////
//////            let shouldSnap = xOffset > 30>>//
//////            didCollapse(viewCollapsed: shouldSnap)
//////
//////            UIViewPropertyAnimator.runningPropertyAnimator(
//////                withDuration: 0.3,
//////                delay: 0, options: .curveEaseInOut) {
//////
//////                    self.objectTableViewTrailingAnchor?.constant = shouldSnap ? 120 : 240
////
////
////                }
////        self.view.layoutIfNeeded()
////        }
////    }
////}
//
//
////MARK: - Set Delegates & Data Source -
//extension ComparisonListViewController {
//    private func setDelegates() {
//        objectTableView.delegate = self
//        objectTableView.dataSource = self
//        objectTableView.register(ObjectTableViewCell.self,
//                                 forCellReuseIdentifier: ObjectTableViewCell.idTableViewCell)
//
//        
//        attributesCollectionView.delegate = self
//        attributesCollectionView.dataSource = self
//        attributesCollectionView.register(AttributesCollectionViewCell.self,
//                                          forCellWithReuseIdentifier: AttributesCollectionViewCell.idAttributesCollectionViewCell)
//        
//        valuesCollectionView.delegate = self
//        valuesCollectionView.dataSource = self
//        valuesCollectionView.register(ValuesCollectionViewCell.self,
//                                      forCellWithReuseIdentifier: ValuesCollectionViewCell.idValuesColectionViewCell)
//        
//        
//                
//        }
//}
//
//
////MARK: -UICollectionViewDataSource
//extension ComparisonListViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        var items = 1
//        
//        switch collectionView {
//            
//        case valuesCollectionView:
//            
//            items = comparisonAttributesFetchResultsController.fetchedObjects?.count ?? 0
//            
//        case attributesCollectionView:
//            items = comparisonAttributesFetchResultsController.fetchedObjects?.count ?? 0
//
//        default:
//            return items
//        }
//        return items
//    }
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        var sections = 1
//        
//        switch collectionView {
//            
//        case valuesCollectionView:
//            sections = comparisonItemsFetchResultsController.fetchedObjects?.count ?? 0
//                        
//        case attributesCollectionView:
//            
//            sections = 1
//            
//        default:
//            sections = 1
//        }
//        return sections
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        var returnedCell = UICollectionViewCell()
//        
//        switch collectionView {
//            
//        case attributesCollectionView:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttributesCollectionViewCell.idAttributesCollectionViewCell, for: indexPath) as? AttributesCollectionViewCell else {
//                return UICollectionViewCell()
//            }
//
//            
//            let attribute = comparisonAttributesFetchResultsController.fetchedObjects![indexPath.row]
//            cell.attributeLabel.text = attribute.unwrappedName
//            cell.index = indexPath
//            cell.isUserInteractionEnabled = true
//            
//            returnedCell = cell
//            
//        case valuesCollectionView:
//            
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ValuesCollectionViewCell.idValuesColectionViewCell, for: indexPath) as? ValuesCollectionViewCell else {
//                return ValuesCollectionViewCell()
//            }
//            
//            let item = comparisonItemsFetchResultsController.fetchedObjects![indexPath.section]
//            let attribute = comparisonAttributesFetchResultsController.fetchedObjects![indexPath.row]
//            
//            
//            let cellValue = sharedData.fetchValue(item: item, attribute: attribute)
//            cell.delegate = self
//            
//            cell.updateButtonTitle(isValueTrue: cellValue.booleanValue)
//            
//            returnedCell = cell
//            
//            
//        default:
//            return returnedCell
//        }
//        
//        return returnedCell
//    }
//    
////    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
////        let reorder = UIAction(title: "Reorder", image: UIImage(systemName: "arrow.right.arrow.left.square.fill")) { [weak self] _ in 
////            
////        }
////    }
//    
//
//}
//
////MARK: -UICollectionViewDelegate
//extension ComparisonListViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("tapped cell: \(indexPath)")
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//        UIContextMenuConfiguration(identifier: "attributeContext" as NSCopying, previewProvider: nil) { _ in
//            self.setupAttributesCellMenu(attribute: ComparisonAttributeEntity())
//            return self.attributeCellMenu
//        }
//    }
//}
//
//
////MARK: -UITableViewDataSource
//extension ComparisonListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView,
//                   numberOfRowsInSection section: Int) -> Int {
//        1
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        guard let sections = comparisonItemsFetchResultsController.fetchedObjects?.count else {
//            return 0
//        }
//        print("sections: \(sections)")
//        return sections
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        guard let comp = comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] else {
//            return UITableViewCell()}
//        
//        guard let cell = objectTableView.dequeueReusableCell(
//            withIdentifier: ObjectTableViewCell.idTableViewCell,
//            for: indexPath) as? ObjectTableViewCell else {
//            return UITableViewCell()
//        }
//        
//        cell.configureCell(comparisonItemEntity: comp)
//        cell.cellCollapseDelegate = self
//        cell.objectTableViewCellDelegate = self
//        
//        return cell
//    }
//    
//    
////    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
////        let headerView = UIView()
////        return headerView
////    }
//    
////    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
////        itemTableFooterHeight
////    }
//    
//}
//
////MARK: UITableViewDelegate
//extension ComparisonListViewController: UITableViewDelegate {
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        itemTableCellHeight = view.frame.height * 0.11
//        return itemTableCellHeight
//    }
//    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        if tableViewIsCollapsed {
//            return nil
//        } else {
//            let action = UIContextualAction(style: .destructive,
//                                            title: "") { [weak self] _ , _, _ in
//                guard let self = self else { return }
//                
//
//                
//                let comparisonItem = self.comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section]
//                self.sharedData.deleteComparisonItem(item: comparisonItem ?? ComparisonItemEntity())
//            }
//            action.backgroundColor = .specialColors.background
//            action.image = UIImage(named: "deleteSwipeButtonFullSize")?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 0)
//            
//            return UISwipeActionsConfiguration(actions: [action])
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        let item = comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section]
//        itemCellTapped(comparisonItem: item ?? ComparisonItemEntity())
//    }
//}
//
//extension ComparisonListViewController {
//    private func itemCellTapped(comparisonItem: ComparisonItemEntity) {
//        let objectDetailsViewController = ObjectDetailsViewController()
//        objectDetailsViewController.transitioningDelegate = self
//        objectDetailsViewController.modalPresentationStyle = .overCurrentContext
//        objectDetailsViewController.setForExistingItem(comparisonItem: comparisonItem)
//        //refresh view
////        objectDetailsViewController.saveCompletion = {(model, flag) in
////            if(flag) {
////                self.setComparisonEntity(comparison: model )
////                
////                UIView.animate(withDuration: 0.3) {
////                    self.objectTableView.reloadData()
////                    self.valuesCollectionView.reloadData()
////                    self.attributesCollectionView.reloadData()
////                }
////            }
////        }
//        
//        objectDetailsViewController.detailsClosingCompletion = { flag in
//            if flag {
//                self.reloadTables()
//            }
//        }
//        present(objectDetailsViewController, animated: true)
//        }
//}
//
////MARK: -NewAttributeAlert
//extension ComparisonListViewController: UITextFieldDelegate {
//    
//    @objc private func textFieldChanged(_ sender: Any) {
//        let textfield = sender as! UITextField
//        guard let textfieldText = textfield.text else { return }
//        print(textfieldText)
//
//        
//        let attrs = comparisonAttributesFetchResultsController.fetchedObjects
//        let attributesNames: [String] = comparisonAttributesFetchResultsController.fetchedObjects?.map { $0.unwrappedName } ?? []
//        self.saveAttributeButtonInAlertChanged?.isEnabled = !textfieldText.trimmingCharacters(in: .whitespaces).isEmpty && !attributesNames.contains(textfieldText)
//    }
//    
//    private func alertNewAttributeConfiguration() {
//        
//        self.addNewAttributeAlert = UIAlertController(
//            title: "Add new attribute",
//            message: "",
//            preferredStyle: .alert)
//        
//        
//        addNewAttributeAlert.addTextField { alertTextfield in
//            alertTextfield.delegate = self
//            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
//            alertTextfield.translatesAutoresizingMaskIntoConstraints = false
//        }
//
//        let saveNewAttributeButton = UIAlertAction(title: "OK", style: .default) {
//            [self, weak addNewAttributeAlert] (_) in
//            DispatchQueue.main.async {
//                
//                let textfieldText = addNewAttributeAlert?.textFields?[0].text ?? "No text"
//                
//                let attributeSavingResult = self.sharedData.createComparisonAttribute(name: textfieldText, relatedComparison: self.comparisonEntity)
//                
//            }
//            
//
//        }
//        
//        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
//            self.addNewAttributeAlert.dismiss(animated: true)
//            self.addNewAttributeAlert = UIAlertController()
//        }
//        
//        addNewAttributeAlert.addAction(saveNewAttributeButton)
//        addNewAttributeAlert.addAction(cancelButton)
//        saveAttributeButtonInAlertChanged = saveNewAttributeButton
//        saveNewAttributeButton.isEnabled = false
//        
//    }
//}
//
//
////MARK: - Working with data
//extension ComparisonListViewController {
//     
//    
//    private func deleteItemFromTable(comparisonItem: ComparisonItemEntity, index: Int) {
//        
//        sharedData.deleteComparisonItem(item: comparisonItem)
//        
//        valuesCollectionView.reloadData()
//    }
//    
//    private func deleteAttributeFromCollection(index: IndexPath){
//        
//        print("Index:", index)
//        let attribute = comparisonAttributesFetchResultsController.fetchedObjects?[index.row] ?? ComparisonAttributeEntity()
//        sharedData.deleteComparisonAttribute(attribute: attribute)
//        
//        toggleWobbleAnimation()
//    }
//    
//    
//    //MARK: Getting data model from MainVC
//            
//            public func setComparisonEntity(comparison: ComparisonEntity) {
//                comparisonEntity = comparison
//                loadSavedData()
//                
//                mainLabel.text = comparisonEntity.unwrappedName
//                
//                customLayout = ValuesCollectionViewLayout(
//                    cellWidth: valueCVCellWidth,
//                    cellHeight: itemTableCellHeight + itemTableFooterHeight )
//
//                valuesCollectionView.collectionViewLayout = customLayout
//                
////                objectTableView.reloadData()
//            }
//
//}
//
//
////MARK: - Constraints
//extension ComparisonListViewController {
//    private func setConstraints() {
//        
//        minConstraintConstant = view.frame.width * 0.25
//        midleConstraintConstant = view.frame.width * 0.5
//        maxConstraintConstant = view.frame.width * 0.7
//        
//        animatedConstraint = attributesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: maxConstraintConstant)
//        
//        changeableConstraint = valuesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: maxConstraintConstant)
//        
//        pinnedConstraint = valuesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: minConstraintConstant)
//        
//        NSLayoutConstraint.activate([
//                        
//            backButton.widthAnchor.constraint(equalToConstant: 33),
//            settingsButton.widthAnchor.constraint(equalToConstant: 33),
//            
//            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            titleStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
//            titleStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
//            titleStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            addAttributeButton.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 10),
//            addAttributeButton.heightAnchor.constraint(equalToConstant: 50),
//            addAttributeButton.trailingAnchor.constraint(equalTo: objectTableView.trailingAnchor),
//            addAttributeButton.widthAnchor.constraint(equalToConstant: 50),
////            addAttributeButton.bottomAnchor.constraint(equalTo: objectTableView.topAnchor),
//            
//            animatedConstraint!,
//            attributesCollectionView.topAnchor.constraint(equalTo: addAttributeButton.topAnchor),
//            attributesCollectionView.heightAnchor.constraint(equalToConstant: 50),
//            attributesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            valuesCollectionView.leadingAnchor.constraint(equalTo: attributesCollectionView.leadingAnchor),
//            valuesCollectionView.topAnchor.constraint(equalTo: attributesCollectionView.bottomAnchor),
//            valuesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            valuesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
//            
//            objectTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            objectTableView.topAnchor.constraint(equalTo: attributesCollectionView.bottomAnchor),
//            objectTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
//            objectTableView.trailingAnchor.constraint(equalTo: attributesCollectionView.leadingAnchor),
//            
//            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
//            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//            addButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17),
//            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17),
//            
//            editingDoneButton.leadingAnchor.constraint(equalTo: objectTableView.leadingAnchor, constant: 5),
//            editingDoneButton.bottomAnchor.constraint(equalTo: objectTableView.topAnchor),
//            editingDoneButton.heightAnchor.constraint(equalTo: addAttributeButton.heightAnchor, multiplier: 1),
////            editingDoneButton.widthAnchor.constraint(equalToConstant: valueCVCellWidth)
////            editingDoneButton.centerYAnchor.constraint(equalTo: addAttributeButton.centerYAnchor)
//            
////            shadowTop.topAnchor.constraint(equalTo: view.topAnchor),
////            shadowTop.bottomAnchor.constraint(equalTo: attributesCollectionView.topAnchor, constant: -5),
////            shadowTop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
////            shadowTop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            shadowBottom.topAnchor.constraint(equalTo: attributesCollectionView.bottomAnchor),
//            shadowBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            shadowBottom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            shadowBottom.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            
//            notchView.heightAnchor.constraint(equalToConstant: 17),
//            notchView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            notchView.topAnchor.constraint(equalTo: view.topAnchor, constant: 13)
//        ])
//    }
//}
//
//
////MARK: - UIScrollViewDelegates
//
//extension ComparisonListViewController: UIScrollViewDelegate {
//    
//    private func scrollViewsSync(scrollView: UIScrollView) {
//        
//        if objectTableActive && scrollView == objectTableView {
//            let yOffset = objectTableView.contentOffset.y
//            valuesCollectionView.contentOffset.y = yOffset
//        }
//
//        if attributesCollectionActive && scrollView == attributesCollectionView {
//            let xOffset = attributesCollectionView.contentOffset.x
//            valuesCollectionView.contentOffset.x = xOffset
//        }
//
//        if !attributesCollectionActive && !objectTableActive && scrollView == valuesCollectionView {
//            let xOffset = valuesCollectionView.contentOffset.x
//            let yOffset = valuesCollectionView.contentOffset.y
//
//            attributesCollectionView.contentOffset.x = xOffset
//            objectTableView.contentOffset.y = yOffset
//        }
//    }
//    
////    private func tableViewSizing(scrollView: UIScrollView) { //tableViewWidthSyncWithScroll initial
////        let currentOffsetX = scrollView.contentOffset.x
////        let scrollDiff = currentOffsetX - previousContentOffsetX
////
////        //Fix jumping when bounce effect
////        let bounceBorderContentOffsetX = -scrollView.contentInset.left
////
////        let contentMovesLeft = scrollDiff > 0 && currentOffsetX > bounceBorderContentOffsetX
////        let contentMovesRight = scrollDiff < 0 && currentOffsetX < bounceBorderContentOffsetX
////
////        let currentConstraintConstant = animatedConstraint!.constant
////        var newConstraintConstant = currentConstraintConstant
////
////        if contentMovesLeft {
////            newConstraintConstant = max(currentConstraintConstant - scrollDiff, minConstraintConstant)
////        } else if contentMovesRight {
////            newConstraintConstant = min(currentConstraintConstant - scrollDiff, maxConstraintConstant)
////        }
////
////
////        if newConstraintConstant != currentConstraintConstant {
////            animatedConstraint?.constant = newConstraintConstant
////            scrollView.contentOffset.x = previousContentOffsetX
////        }
////
////        animatedConstraint?.constant = newConstraintConstant
////
////        previousContentOffsetX = scrollView.contentOffset.x
////    }
////    private func fixYoffset(scrollView: UIScrollView) {
////        let valuesYoffset = valuesCollectionView.contentOffset.y
////        print("Start position: OffsetValues =\(valuesYoffset), OffsetObjects =\(objectTableView.contentOffset.y)")
////
////        objectTableView.contentOffset.y = valuesYoffset
////        self.objectTableView.layoutIfNeeded()
////        print("Fin position: OffsetValues =\(valuesYoffset), OffsetObjects =\(objectTableView.contentOffset.y)")
////    }
//    
//    
//    private func sizingViewsWithScrollAnimation(scrollView: UIScrollView) {
//        let leftMovementResizingPoint = maxConstraintConstant - 30
//        let rightMovementResizingPoint = minConstraintConstant + 30
//        
////        let reverseLeftMovement = maxConstraintConstant - 19
////        let reverseRightMovement = minConstraintConstant + 14
//        
//        var swipes = 0
//
////        print("Anim constraint: ", animatedConstraint?.constant, "LeftMovementOpenPoint: ", leftMovementOpenPoint,
////        "max: ", maxConstraintConstant, "min: ", minConstraintConstant)
//
//        let currentOffsetX = scrollView.contentOffset.x
//        let scrollDiff = currentOffsetX - previousContentOffsetX
//
//        let bounceBorderContentOffsetX = -scrollView.contentInset.left
//
////        let contentMovesLeft = scrollDiff > 0 && currentOffsetX > bounceBorderContentOffsetX
////        let contentMovesRight = scrollDiff < 0 && currentOffsetX < bounceBorderContentOffsetX
//        
//        if animatedConstraint?.constant == minConstraintConstant {
//            tableCompressed = true
//        }
//        
//        if animatedConstraint?.constant == maxConstraintConstant {
//            tableCompressed = false
//        }
//        
//        
//        ///////////
//        if animatedConstraint?.constant ?? minConstraintConstant > rightMovementResizingPoint && tableCompressed == true { //растягивает tablewView
//            let generator = UISelectionFeedbackGenerator()//UIImpactFeedbackGenerator(style: .light)
//            generator.selectionChanged()//impactOccurred()
//
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
//                self.animatedConstraint?.constant = self.maxConstraintConstant
//                self.tableCompressed = false
//                print("rastyanuto", self.tableCompressed)
//                self.view.layoutIfNeeded()
//            }
//        } else if tableCompressed == true {
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
//                self.animatedConstraint?.constant = self.minConstraintConstant
//                self.tableCompressed = true
//                print("sjato", self.tableCompressed, swipes)
//                self.view.layoutIfNeeded()
//            }
//        }
//        
//        if animatedConstraint?.constant ?? maxConstraintConstant < leftMovementResizingPoint && tableCompressed == false { //сжимает tableView
//            
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
//                self.animatedConstraint?.constant = self.minConstraintConstant
//                self.tableCompressed = true
//                print("sjato", self.tableCompressed, swipes)
//                self.view.layoutIfNeeded()
//            }
//        } else if tableCompressed == false {
//            
//            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.2, delay: 0) {
//                self.animatedConstraint?.constant = self.maxConstraintConstant
//                self.tableCompressed = false
//                print("rastyanuto", self.tableCompressed)
//                self.view.layoutIfNeeded()
//            }
//        }
//        //////
//        ///
//        ///
//        didCollapse(viewCollapsed: tableCompressed)
//    }
//    
//    private func tableViewWidthSyncWithScroll(scrollView: UIScrollView) {  //синхронизирует h-скролл коллекции и ширину tableView
//        let currentOffsetX = scrollView.contentOffset.x
//        let scrollDiff = currentOffsetX - previousContentOffsetX
//        
//        let bounceBorderContentOffsetX = -scrollView.contentInset.left
//        
//        let contentMovesLeft = scrollDiff > 0 && currentOffsetX > bounceBorderContentOffsetX
//        let contentMovesRight = scrollDiff < 0 && currentOffsetX < bounceBorderContentOffsetX
//        
//        let currentConstraintConstant = animatedConstraint!.constant
//        var newConstraintConstant = currentConstraintConstant
//        
//
//        
//        if contentMovesLeft {
//            newConstraintConstant = max(currentConstraintConstant - scrollDiff, minConstraintConstant)
//            
//        } else if contentMovesRight && !tableViewWidthFixed {
//            newConstraintConstant = min(currentConstraintConstant - scrollDiff, maxConstraintConstant)
//        }
//        
//        if newConstraintConstant != currentConstraintConstant {
//            animatedConstraint?.constant = newConstraintConstant
//            scrollView.contentOffset.x = previousContentOffsetX
//        }
//        
//        animatedConstraint?.constant = newConstraintConstant
//        previousContentOffsetX = scrollView.contentOffset.x
////        self.fixYoffset(scrollView: scrollView)
//    }
//
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        objectTableActive = scrollView == objectTableView
//        attributesCollectionActive = scrollView == attributesCollectionView
//        
//        if (animatedConstraint?.constant == minConstraintConstant && scrollView.contentOffset.x > 10) || isEditing {
//            tableViewWidthFixed = true
//            print("tableViewWidthFixed: ", tableViewWidthFixed)
//        } else {
//            tableViewWidthFixed = false
//            print("tableViewWidthFixed: ", tableViewWidthFixed)
//        }
//        
//        
//    }
//
//    
//    
////MARK: ! unmute block
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        let xOffset = scrollView.contentOffset.x
////        print("xOffset: ",xOffset)
//        scrollViewsSync(scrollView: scrollView)
//
//
//        shouldSnap = xOffset > 20
//        
//        tableViewIsCollapsed = shouldSnap
////        didCollapse(viewCollapsed: shouldSnap)
//        
////        tableViewSizing(scrollView: scrollView)
////        sizingViewsWithScroll(scrollView: scrollView)
//
//            tableViewWidthSyncWithScroll(scrollView: scrollView)
//   
//        
//        //MARK: bounce compensation
////        let maxOffset: CGFloat = (scrollView.contentSize.height - scrollView.frame.size.height)
////        let originOffset = 0
////        
////        if scrollView.contentOffset.y >= maxOffset {
////            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, maxOffset)
////        }
//        
//        
//        
//    }
//    
////    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        if attributesCollectionActive && scrollView == attributesCollectionView {
////            let xOffset = attributesCollectionView.contentOffset.x
////            valuesCollectionView.contentOffset.x = xOffset
////            
////            let shouldSnap = xOffset > 40
////            
////            didCollapse(viewCollapsed: shouldSnap)
////            UIViewPropertyAnimator.runningPropertyAnimator(
////                withDuration: 0.3,
////                delay: 0) {
////                    self.attributesCVLeadingAnchor?.constant = shouldSnap ? 100 : 160
////                }
////        }
////    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//            dispatchScrollViewInteractionUpdate(scrollView: scrollView)
//    }
//    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
////            sizingViewsWithScroll(scrollView: scrollView)
//            dispatchScrollViewInteractionUpdate(scrollView: scrollView)
//    }
//    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        dispatchScrollViewInteractionUpdate(scrollView: scrollView)
//        
//        
//    }
//    
//    private func dispatchScrollViewInteractionUpdate(scrollView: UIScrollView) {
//        DispatchQueue.main.async {
//            self.updateScrollViewInteraction(scrollView: scrollView)
//        }
//    }
//    
//    private func updateScrollViewInteraction(scrollView: UIScrollView) {    //check if scrolling finished
//        if !scrollView.isDragging
//            && !scrollView.isDecelerating
//            && !scrollView.isZoomBouncing
//            && !scrollView.isTracking
//            && !scrollView.isZooming
//            
//        {
//            sizingViewsWithScrollAnimation(scrollView: scrollView)
//            
//        }
//    }
//    
//    
////    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
////        let leftMovementOpenPoint = maxConstraintConstant - 40
////        let rightMovementClosePoint = minConstraintConstant + 60
////
////        print("Anim constraint: ", animatedConstraint?.constant, "LeftMovementOpenPoint: ", leftMovementOpenPoint,
////        "max: ", maxConstraintConstant, "min: ", minConstraintConstant)
////
////        let currentOffsetX = scrollView.contentOffset.x
////        let scrollDiff = currentOffsetX - previousContentOffsetX
////
////        let bounceBorderContentOffsetX = -scrollView.contentInset.left
////
////        let contentMovesLeft = scrollDiff > 0 && currentOffsetX > bounceBorderContentOffsetX
////        let contentMovesRight = scrollDiff < 0 && currentOffsetX < bounceBorderContentOffsetX
////
////        if animatedConstraint?.constant ?? minConstraintConstant > leftMovementOpenPoint {
////            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
////                self.animatedConstraint?.constant = self.maxConstraintConstant
////                self.view.layoutIfNeeded() }
////        }
////
////        if animatedConstraint?.constant ?? maxConstraintConstant < leftMovementOpenPoint {
////            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
////                self.animatedConstraint?.constant = self.minConstraintConstant
////                self.view.layoutIfNeeded() }
////        }
////    }
//}
//
//extension ComparisonListViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return navigationController?.viewControllers.count ?? 2 > 1
//    }
//}
//
////extension ComparisonListViewController {
////    @objc func editButtonTapped() {
////        objectTableView.setEditing(!objectTableView.isEditing, animated: true)
////    }
////}
//
////MARK: - ToggleWobbleAnimation
//extension ComparisonListViewController {
//    @objc func toggleWobbleAnimation() {
//        if
//            self.attributesCollectionView.isEditing == true {
//            
//            if shouldReturnPosition == true {
//                
//                UIView.animate(withDuration: 0.3) {
//                    self.animatedConstraint?.constant = self.maxConstraintConstant
//                    
//                    self.setEditing(false, animated: true)
//                    self.attributesCollectionView.isEditing = false
//                    self.settingsButton.isUserInteractionEnabled = true
//                    self.editingDoneButton.isHidden = true
//                    
//                    self.settingsButton.isHidden = true
//                    
//                    self.shadowTop.isHidden = true
//                    self.shadowBottom.isHidden = true
//                    self.shouldReturnPosition = false
//                }
//                
//            } else if shouldReturnPosition == false {
//                
//                self.setEditing(false, animated: true)
//                self.attributesCollectionView.isEditing = false
//                self.settingsButton.isUserInteractionEnabled = true
//                self.editingDoneButton.isHidden = true
//                
//                self.settingsButton.isHidden = true
//                
//                self.shadowTop.isHidden = true
//                self.shadowBottom.isHidden = true
//            }
//            
//            
//            
//            //clear all animations
//            
//            self.attributesCollectionView.indexPathsForVisibleItems.forEach { (indexPath) in
//                let cell = self.attributesCollectionView.cellForItem(at: indexPath) as! AttributesCollectionViewCell
//                cell.isEditing = false
//                cell.layer.removeAllAnimations()
//            }
//    } else {
//            setEditing(true, animated: true)
//            
//            //create animation
//            let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
//            wobble.values = [0.0, -0.05, 0.0, 0.05, 0.0]
//            wobble.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
//            wobble.duration = 0.4
//            wobble.isAdditive = true
//            wobble.repeatCount = Float.greatestFiniteMagnitude
//            
//            // add nimation to each collection view cell
//            self.attributesCollectionView.indexPathsForVisibleItems.forEach { (indexPath) in
//                let cell = self.attributesCollectionView.cellForItem(at: indexPath) as! AttributesCollectionViewCell
//                cell.isEditing = true
//                cell.layer.add(wobble, forKey: "wobble")
//            }
//            self.attributesCollectionView.isEditing = true
//            
//            settingsButton.isUserInteractionEnabled = false
//            editingDoneButton.isHidden = false
//            
//            shadowTop.isHidden = false
//            shadowBottom.isHidden = false
//        }
//    }
//}
//
//extension ComparisonListViewController: DeleteAttributeCellProtocol {
//    func deleteAttribute(index: IndexPath) {
//        
//
//        
//        self.deleteAttributeFromCollection(index: index)
//    }
//    
////    @objc private func attributeCellLongPressed(gesture: UILongPressGestureRecognizer!) {
////        if gesture.state != .ended {
////            print("!= ended")
////            return
////        }
////
////        let press = gesture.location(in: attributesCollectionView)
////
////        if let indexPath = self.attributesCollectionView.indexPathForItem(at: press) {
////            let cell = self.attributesCollectionView.cellForItem(at: indexPath)
////            toggleWobbleAnimation()
////            print("long press")
////        } else {
////            print("couldn`t find index path")
////        }
////    }
//    
////    private func addDismissGesture() {
////        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(sender:)))
////        gesture.direction = .right
////        view.addGestureRecognizer(gesture)
////    }
////
////    @objc private func swipeAction(sender: UISwipeGestureRecognizer) {
////        let location = sender.location(in: view)
////        if location.x < (view.frame.width - titleStackView.frame.width) / 2  {
////
////            dismiss(animated: true)
////        }
////    }
//    
//    private func addLongPress() {
//        
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(sender:)))
//        
//        attributesCollectionView.addGestureRecognizer(gesture)
//        gesture.delegate = self
//        
//        
//        
////        let tapges = UITapGestureRecognizer(target: self, action: #selector(longPressAction(sender:)))
////        
////        valuesCollectionView.addGestureRecognizer(tapges)
////        tapges.delegate = self
//        
//    }
//    
//    @objc func longPressAction(sender: UILongPressGestureRecognizer) {
//        
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.impactOccurred()
//        
//        let location = sender.location(in: attributesCollectionView)
//        
//        print("long press")
////        if shouldSnap {
////            
////            shouldReturnPosition = false
////            
////            if let indexPath = self.attributesCollectionView.indexPathForItem(at: location) {
////                if !isEditing {
////                    toggleWobbleAnimation()
////                    print("longPress", indexPath)
////                } else {
////                    print("couldn`t find indexPath")
////                }
////            }
////        } else if shouldSnap == false {
////            
////            print("location of longPress:", location)
////            print(attributesCollectionView.frame.maxX, "maxX",
////                  attributesCollectionView.frame.minX, "minX",
////                  attributesCollectionView.frame.maxY, "maxY",
////                  attributesCollectionView.frame.minY, "minY")
////            
////
////            
////            
////            if location.y < attributesCollectionView.frame.height && attributesCollectionView.numberOfItems(inSection: 0) != 0 {
////                shouldReturnPosition = true
////                animatedConstraint?.constant = minConstraintConstant
////            }
////////                &&
////////                   location.y <  attributesCollectionView.frame.maxY &&
////////                   attributesCollectionView.frame.minX > location.x
//////                animatedConstraint?.constant = minConstraintConstant
//////            }
////            
//////            if sender.view?.frame ==
////
////                        
////            if let indexPath = self.attributesCollectionView.indexPathForItem(at: location) {
////                if !isEditing {
////                    toggleWobbleAnimation()
////                    print("longPress", indexPath)
////                } else {
////                    print("couldn`t find indexPath")
////                }
////            }
////        }
//    }
//}
//
//
//extension ComparisonListViewController {
//    private func addGestureForShadows() {
//        let tapTopShadow = UITapGestureRecognizer(target: self, action: #selector(hideShadow(recogniser:)))
//        self.shadowTop.addGestureRecognizer(tapTopShadow)
//        
//        let tapBotShadow = UITapGestureRecognizer(target: self, action: #selector(hideShadow(recogniser:)))
//        self.shadowBottom.addGestureRecognizer(tapBotShadow)
//        
////        let swipeTopShadow = UISwipeGestureRecognizer(target: self, action: #selector(hideShadow))
////        swipeTopShadow.cancelsTouchesInView = false
////        view.addGestureRecognizer(swipeTopShadow)
////
////        let swipeBotShadow = UISwipeGestureRecognizer(target: self, action: #selector(hideShadow))
////        swipeBotShadow.cancelsTouchesInView = false
////        view.addGestureRecognizer(swipeBotShadow)
//        }
//    
//    @objc private func hideShadow(recogniser: UITapGestureRecognizer) {
//        print (recogniser.description)
//        toggleWobbleAnimation()
////        isEditing = false
//        print("shadowTapped")
//    }
//    
//    private func addBlurToShadow() {
////        let blurViewTop = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
////        blurViewTop.frame = shadowTop.bounds
////        blurViewTop.alpha = 0.2
////        blurViewTop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        shadowTop.insertSubview(blurViewTop, at: 0)
//        
//        let blurViewBot = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurViewBot.frame = shadowBottom.bounds
//        blurViewBot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        shadowBottom.addSubview(blurViewBot)
//        shadowBottom.insertSubview(blurViewBot, at: 0)
//        
//        print(blurViewBot.alpha)
//        print("blur added")
//    }
//}
//
//
//////
////extension ComparisonListViewController: UIScrollViewDelegate {
////
////    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
////        objectTableActive = scrollView == objectTableView
////        attributesCollectionActive = scrollView == attributesCollectionView
////    }
////
////
////    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////
////        let xOffset = scrollView.contentOffset.x
////
////        let shouldSnap = xOffset > 20
////
////        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: []) {
////            self.animatedConstraint?.constant = shouldSnap ? self.minConstraintConstant : self.maxConstraintConstant
////            print(shouldSnap, xOffset)
////            self.view.layoutIfNeeded()
////        }
////
////
////
////
//////
//////        let currentOffsetX = scrollView.contentOffset.x
//////        let scrollDiff = currentOffsetX - previousContentOffsetX
//////
//////        print("scrollDiff: ", scrollDiff.description as Any)
//////        print("contentOffsetX: ", scrollView.contentOffset.x)
//////
//////        //Fix jumping when bounce effect
//////        let bounceBorderContentOffsetX = -scrollView.contentInset.left
//////
//////        let contentMovesLeft = scrollDiff > 0 && currentOffsetX > bounceBorderContentOffsetX
//////        let contentMovesRight = scrollDiff < 0 && currentOffsetX < bounceBorderContentOffsetX
//////
//////        let currentConstraintConstant = animatedConstraint!.constant
//////        var newConstraintConstant = currentConstraintConstant
//////        if contentMovesLeft {
//////            newConstraintConstant = max(currentConstraintConstant - scrollDiff, midleConstraintConstant)
//////
//////
//////            //            if newConstraintConstant == minConstraintConstant {
//////            //                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
//////            //                    self.animatedConstraint?.constant = self.minConstraintConstant
//////            //                    self.view.layoutIfNeeded()
//////            //                }
//////            //            }
//////        } else if contentMovesRight {
//////            newConstraintConstant = min(currentConstraintConstant - scrollDiff, maxConstraintConstant)
//////        }
//////
//////        if newConstraintConstant != currentConstraintConstant {
//////            animatedConstraint?.constant = newConstraintConstant
//////            scrollView.contentOffset.x = previousContentOffsetX
//////        }
//////
////////        if currentConstraintConstant == midleConstraintConstant {
//////
////////                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
////////
////////                    self.changeableConstraint = self.pinnedConstraint
////////                self.animatedConstraint?.constant = self.minConstraintConstant
////////                self.view.layoutIfNeeded()
////////            }
////////        }
//////
//////
//////
//////
//////        print("scrollDiff2: ", scrollDiff.description as Any)
//////        print("contentOffsetX2: ", scrollView.contentOffset.x)
//////
//////        animatedConstraint?.constant = newConstraintConstant
//////
//////        previousContentOffsetX = scrollView.contentOffset.x
//////
//////
//////
//////
//////
////                if objectTableActive && scrollView == objectTableView {
////                    let yOffset = objectTableView.contentOffset.y
////                    valuesCollectionView.contentOffset.y = yOffset
////                }
////
////                if attributesCollectionActive && scrollView == attributesCollectionView {
////                    let xOffset = attributesCollectionView.contentOffset.x
////                    valuesCollectionView.contentOffset.x = xOffset
////                }
////
////                if !attributesCollectionActive && !objectTableActive && scrollView == valuesCollectionView {
////                    let xOffset = valuesCollectionView.contentOffset.x
////                    let yOffset = valuesCollectionView.contentOffset.y
////
////                    attributesCollectionView.contentOffset.x = xOffset
////                    objectTableView.contentOffset.y = yOffset
////                }
////////
////////
////////        let xOffset = scrollView.contentOffset.x
////////        let shouldSnap = xOffset > 20
////////
////////        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3,
////////                                                       delay: 0) {
////////
////////            self.animatedConstraint?.constant = shouldSnap ? 120 : 240
////////            print(shouldSnap, xOffset)
////////            }
////    }
////}
//
//
//extension ComparisonListViewController: valuesCollectionViewCellDelegate, ObjectTableViewCellProtocol {
//    func isCellCollapsedNow() -> Bool {
//        let report = objectTableView.frame.width > 240 ? false : true
//        return report
//    }
//    
//    func refreshCellWhenValueChanges() {
//        print("")
//    }
//    
//    
//    func didTapValueButton(cell: ValuesCollectionViewCell) {
//        
//        if let indexPath = valuesCollectionView.indexPath(for: cell) {
//            let item = comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] ?? ComparisonItemEntity()
//            
//            let attribute = comparisonAttributesFetchResultsController.fetchedObjects?[indexPath.row] ?? ComparisonAttributeEntity()
//            
//            let value = sharedData.fetchValue(item: item, attribute: attribute)
//            sharedData.changeBooleanValue(for: value)
//            
//            
//            refreshCellWhenValueChanges(indexPath: indexPath, item: item)
//            
//            //??????
//            self.valuesCollectionView.reloadItems(at: [indexPath])
//                        
////            UIView.animate(withDuration: 0.3) {
////                self.objectTableView.reloadSections(IndexSet(integer: indexPath.section), with: .none
////                )
////            }
//        }
//        
//        
//
////        self.objectTableView.reloadData()
//    }
//    
//    
//    func refreshCellWhenValueChanges(indexPath: IndexPath, item: ComparisonItemEntity){
//        let valueCellPath = indexPath
//        let changedItem = item
//        let objectTableviewCellPath = indexPath.section
//        print(indexPath)
//        let relatedObjectTableViewCell = objectTableView.cellForRow(at: IndexPath(row: 0, section: valueCellPath.section)) as? ObjectTableViewCell
//        relatedObjectTableViewCell?.valueChangedRefresh(comparisonItemEntity: item)
//    }
//}
//
//
//extension ComparisonListViewController {
//    func openDetailsForNewComparison() {
//        self.addButtonTapped()
//    }
//}
//
//
//extension ComparisonListViewController {
//}
