//
//  objectDetailsViewController.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 04.04.2023.
//
import Foundation
import UIKit

protocol ObjectDetailsVCProtocol: AnyObject {
    func creatingIsComplete(comparisonEntity: ComparisonEntity)
}



class ObjectDetailsViewController:  DraggableViewController, UIViewControllerTransitioningDelegate, DraggableViewControllerProtocol {

    private var sharedData = CoreDataManager.shared
    var dismissAttributeChangeNameAlertGesture = UITapGestureRecognizer()
    weak var saveAttributeButtonInAlertChanged: UIAlertAction?

    //  { DraggableViewController
        
//    override var axis: NSLayoutConstraint.Axis = .vertical
//    override var axis: NSLayoutConstraint.Axis = .vertical
    
    var attributeChangeNameAlert:
    UIAlertController? = UIAlertController(
        title: "Edit attribute",
        message: "",
        preferredStyle: .alert)
    
    var deleteItemAlert:
    UIAlertController? = UIAlertController(
        title: "Delete",
        message: "",
        preferredStyle: .alert)
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    weak var endCreatingDelegate: ObjectDetailsVCProtocol?
        
    typealias completion = (Bool) -> Void
    var detailsClosingCompletion: completion!
    
    private var needUpdate = false //true if this VC opened from ComparisonListViewController(CVC) and CVC must be updated; false if this VC opened from MainViewController and CVC will be started in next step
    private var isNewItem = true // false if opened for existing item. Using from ComparisonListViewController only
    
    
    
    private let sharedDataBase = CoreDataManager.shared

    private var comparisonItemModel: ComparisonItemEntity?
    private var comparisonModel: ComparisonEntity?
    private var attributesArray: [ComparisonAttributeEntity] = []
    
    private let warningMessageEmoji = ["😉", "💁‍♂️", "👻", "🙀", "🥈", "🚧", "❣️", "🥸", "👯", "🙃", "🧐", "🤓", "🤔"]
    private var blurVisualEffectView = UIVisualEffectView()
    
    weak var saveButtonInAlertChanged: UIAlertAction?
    private var lastPresentingVC: String?
    
    
//    public let createNewComparisonListAlert = UIAlertController(
//        title: "New comparisons list",
//        message: "",
//        preferredStyle: .alert)
    
    private var addNewAttributeAlert = UIAlertController(
        title: "New attribute",
        message: "Enter attribute for comparison",
        preferredStyle: .alert)
    
//    private var deleteItemAlert = UIAlertController(
//        title: "Are you shure?", message: "Item will be deleted)", preferredStyle: .alert)
    
    private var blurInactiveArea: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var blureAreaLabel: UILabel = {
        let label = UILabel()
        label.text = "Create item to continue"
        label.font = .sfProTextRegular23()
        label.textColor = UIColor.specialColors.detailsOptionTableText//UIColor.specialColors.plaseholder
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    

//    private var velocityDismiss: CGFloat = 300
//    private let percentThresholdDismiss: CGFloat = 0.3
    
    private let closeButton = CloseButton()
    private let detailsView = DetailsView()
    private let attributesTableView = AttributesTableView()
    private let addNewAttributeButton = AddAttributeButton(title: "+ Add attribute")
    private let deleteItemButton = DeleteItemButton(title: "Delete item")
    
    var cellsCount = 5
    
    
//    override var shouldAutorotate: Bool { return false }
//    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.portrait
//    }
//
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return UIInterfaceOrientation.portrait
//    }
    
    
    
    override func setNeedsUpdateOfSupportedInterfaceOrientations() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isNewItem {
            detailsView.newItemTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attributesTableView.allowsSelection = false
        setupViews()
        setConstraints()
        addGesture()
        setDelegates()
        
        print("VC in NC:", navigationController?.viewControllers ?? "nil.",
              "Presenting VC:", presentingViewController ?? "nil.",
              "Presentation controller:", presentationController ?? "nil",
              "presentationController?.presentedViewController:", presentationController?.presentedViewController ?? "nil",
              "presentingViewController.navigationController", presentingViewController?.navigationController ?? "nil"
        )
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        ScreenOrientationUtility.lockOrientation(.portrait)
        
        closeButton.layer.cornerRadius = closeButton.frame.width / 2
        
        
//        presentingVC()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ScreenOrientationUtility.lockOrientation(.all)
        
        //save item
        
    }
        
    private func setupViews() {
        
        view.clipsToBounds = true
        
        view.layer.cornerRadius = 34
        view.backgroundColor = .specialColors.background
        view.backgroundColor = .specialColors.background

        view.addSubview(detailsView)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        view.addSubview(attributesTableView)
        
        addNewAttributeButton.addTarget(self, action: #selector(addNewAttributeButtonTapped), for: .touchUpInside)
        view.addSubview(addNewAttributeButton)
//        deleteItemButton.addTarget(self, action: #selector(deleteItemTapped), for: .touchUpInside)
//        view.addSubview(deleteItemButton)
                
//        view.addGestureRecognizer(UIPanGestureRecognizer(target: self,
//                                                         action: #selector(onDragY(_:))))  //dragging with pan animated needs to fix
    }
    
    private func addGesture() {
        
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapScreen)
        
//        let swipeToDismiss = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(sender:)))
//        swipeToDismiss.direction = .down
//        view.addGestureRecognizer(swipeToDismiss)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
//    @objc private func swipeAction(sender: UISwipeGestureRecognizer) {
//        let location = sender.location(in: detailsView)
//
//
//        if location.y <  detailsView.frame.height {
//            closeButtonTapped()
//        }
//    }
    
    

//MARK: CloseButtonTapped (saving, dismissing, refreshing(closure) / opening(delegate) objListVC)
    
    func willDismissView() {
        self.detailsClosingCompletion(true)
    }
        
//    @objc private func closeButtonTapped() { //Alt
//        guard let enteredName = detailsView.newItemTextField.text else {
//            print("textfield is empty")
//            return
//        }
//        
//        //        print("Name in textfield - \(enteredName)")
//        //
//        //        let enteredNameWithoutSpaces = enteredName.replacingOccurrences(of: " ", with: "")
//        //        let nameIsEmpty = enteredName == enteredNameWithoutSpaces
//        
//        switch isNewItem {
//        case true:
//            
//            print(self.needUpdate, "isNewItem - true")
//            detailsView.newItemTextField.endEditing(true)
//            self.detailsClosingCompletion(true)
//            dismiss(animated: true)
//            return
//        case false:
//            print(self.needUpdate, "isNewItem - false")
//            if enteredName != comparisonItemModel?.unwrappedName && enteredName != "" {
//                updateExistingItem(comparisonItem: comparisonItemModel ?? ComparisonItemEntity(), newName: enteredName)
//                print("item name changed")
//                self.detailsClosingCompletion(true)
//                dismiss(animated: true)
//                return
//            } else {
//                dismiss(animated: true)
//                print("isNewItem-false, enteredName wrong")
//                return
//            }
//        }
//        
//        print(self.needUpdate, "is newItem ignored")
////         self.detailsClosingCompletion()
//        self.endCreatingDelegate?.creatingIsComplete(comparisonEntity: comparisonItemModel?.comparison ?? ComparisonEntity())
//        dismiss(animated: true)
//        return
//    }
    
    @objc func closeButtonTapped() {
        self.startClosingAnimation(type: .button)
    }
    
    
//    @objc private func closeButtonTapped() {
//        guard let enteredName = detailsView.newItemTextField.text else {
//            print("name - nil")
//            return }
//        print("name = \(enteredName)")
//        
//
//            
//            if isNewItem {
//                
//                if enteredName == "" {
//                    dismiss(animated: true)}
//                else {
//                    guard let comparisonEntity = comparisonModel else {
//                        print("compEntity - nil")
//                        dismiss(animated: true)
//                        return }
//                    
//                    
//                    let presentingVC = presentingViewController?.description ?? "Navigation" //nil when opened from mainVC (as navigationController)
//                    
//                    
//                    self.saveNewItem(name: enteredName, comparisonEntity: comparisonEntity, color: detailsView.itemColorName ?? "sixGreenMagicMint")
//                    
//                    switch self.needUpdate {  //updating when opdened from ComparisonList
//                    case false:
//                        print("открыто из MainVC")
//                        print(presentingVC)
//                        self.dismiss(animated: true) {
//                            self.endCreatingDelegate?.creatingIsComplete(comparisonEntity: comparisonEntity)
//                        }
//                        
//                    case true:
//                        print("открыто из ComparisonListVC")
//                        self.saveCompletion(comparisonEntity, true)
//                        self.dismiss(animated: true) {
//                            self.saveCompletion(comparisonEntity, true)
//                        }
//                    }
//                }
//            } else {
//                if enteredName != comparisonItemModel?.unwrappedName && enteredName != "" {
//                    updateExistingItem(comparisonItem: comparisonItemModel ?? ComparisonItemEntity(), newName: enteredName)
//                    print("item name changed")
//                    dismiss(animated: true) {
//                        self.saveCompletion(self.comparisonItemModel?.comparison ?? ComparisonEntity(), true)
//
//                    }
//                }
//            }
//            dismiss(animated: true)
//        }
    //MARK: -----------------*************________--------****************---------__________************__________------------------
//    @objc private func deleteItemTapped() {
//        
//        
//        detailsView.configureForExistedItem(comparisonItem: comparisonItemModel ?? ComparisonItemEntity())
//        
//        deleteItemAlertConfiguration()
//        present(deleteItemAlert!, animated: true)
//    }
    
    @objc private func addNewAttributeButtonTapped() {
        addAttributeAlertConfiguration()
        present(addNewAttributeAlert, animated: true)
    }
    
    //MARK: - StatusBar

   override var prefersStatusBarHidden: Bool {
       return true
   }
}

//MARK: - Constraints

//extension ObjectDetailsViewController {
//    private func setConstraints() {
//        
//        portraitConstraints = [
//        
//            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),
//            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            closeButton.heightAnchor.constraint(equalToConstant: 29),
//            closeButton.widthAnchor.constraint(equalToConstant: 29),
//            
//            detailsView.topAnchor.constraint(equalTo: view.topAnchor),
//            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            detailsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.378),
//            
//            addNewAttributeButton.topAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: 10),
//            addNewAttributeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
//            addNewAttributeButton.heightAnchor.constraint(equalToConstant: 45),
//            addNewAttributeButton.widthAnchor.constraint(equalToConstant: 130),
//            
//            attributesTableView.topAnchor.constraint(equalTo: addNewAttributeButton.bottomAnchor, constant: 10),
//            attributesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            attributesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            attributesTableView.bottomAnchor.constraint(equalTo: deleteItemButton.topAnchor, constant: -10),
//
//            deleteItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
//            deleteItemButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            deleteItemButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            deleteItemButton.heightAnchor.constraint(equalToConstant: 44)
//        ]
//        
//        landscapeConstraints = [
//        
//            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),
//            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
//            closeButton.heightAnchor.constraint(equalToConstant: 29),
//            closeButton.widthAnchor.constraint(equalToConstant: 29),
//            
//            detailsView.topAnchor.constraint(equalTo: view.topAnchor),
//            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            detailsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.378),
//            
//            addNewAttributeButton.topAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: 10),
//            addNewAttributeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
//            addNewAttributeButton.heightAnchor.constraint(equalToConstant: 45),
//            addNewAttributeButton.widthAnchor.constraint(equalToConstant: 130),
//            
//            attributesTableView.topAnchor.constraint(equalTo: addNewAttributeButton.bottomAnchor, constant: 10),
//            attributesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            attributesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            attributesTableView.bottomAnchor.constraint(equalTo: deleteItemButton.topAnchor, constant: -10),
//
//            deleteItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
//            deleteItemButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            deleteItemButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            deleteItemButton.heightAnchor.constraint(equalToConstant: 44)
//            
//            
//        ]
//    }
//}



extension ObjectDetailsViewController {
    private func setConstraints()  {
        NSLayoutConstraint.activate([
            
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 21),//(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0.026),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),//(equalToSystemSpacingAfter: view.trailingAnchor, multiplier: 0.053),
            closeButton.heightAnchor.constraint(equalToConstant: 29),
            closeButton.widthAnchor.constraint(equalToConstant: 29),
            
            detailsView.topAnchor.constraint(equalTo: view.topAnchor),
            detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            detailsView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.378),
            
            addNewAttributeButton.topAnchor.constraint(equalTo: detailsView.bottomAnchor, constant: 10),
            addNewAttributeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            addNewAttributeButton.heightAnchor.constraint(equalToConstant: 45),
            addNewAttributeButton.widthAnchor.constraint(equalToConstant: 130),
            
            attributesTableView.topAnchor.constraint(equalTo: addNewAttributeButton.bottomAnchor, constant: 10),
            attributesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            attributesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
//            attributesTableView.heightAnchor.constraint(equalToConstant: CGFloat(attributesTableView.cellsCount * 45)),
            attributesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
//            addNewAttributeButton.topAnchor.constraint(equalTo: attributesTableView.bottomAnchor, constant: 0),
//            addNewAttributeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
//            addNewAttributeButton.heightAnchor.constraint(equalToConstant: 45),
//            addNewAttributeButton.widthAnchor.constraint(equalToConstant: 130),


//            deleteItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
////            deleteItemButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
//            deleteItemButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            deleteItemButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            deleteItemButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

extension ObjectDetailsViewController {

}

//MARK: - Alerts configuration

//MARK: addAttributeAlertConfiguration
extension ObjectDetailsViewController {
    private func addAttributeAlertConfiguration() {
        
        self.addNewAttributeAlert = UIAlertController(
            title: "New attribute",
            message: "",
            preferredStyle: .alert)
        
        addNewAttributeAlert.addTextField { alertTextfield in
            alertTextfield.delegate = self
            alertTextfield.placeholder = "New attribute"
            alertTextfield.autocapitalizationType = .sentences
            alertTextfield.becomeFirstResponder()
            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
        }
        
        
        let cancelNewAttributeButton = UIAlertAction(title: "Cancel", style: .cancel) {[weak self] _ in
            self?.addNewAttributeAlert.dismiss(animated: true)
            self?.addNewAttributeAlert = UIAlertController()
        }
        
        addNewAttributeAlert.addAction(cancelNewAttributeButton)
        
        let saveNewAttributeButton = UIAlertAction(title: "Save", style: .default) { [weak  self] _ in
            guard let self = self else { return }
            let textfieldText = self.addNewAttributeAlert.textFields?[0].text ?? "No text"
            
            self.sharedDataBase.createComparisonAttribute(
                name: 
                    textfieldText,
                relatedComparison: 
                    self.comparisonItemModel?.comparison ?? ComparisonEntity()) 
            { _ in
                self.updateAfterAddingAttr()
            }
            
            //            if savingResult == false {
//                print("new attribute wasn`t created")
//            } else {
//                
//                self.updateAfterAddingAttr()
//
//            }
//            
//            self.updateAfterAddingAttr()

//            self?.addNewAttributeAlert.dismiss(animated: true)
//            self?.addNewAttributeAlert = UIAlertController()
//            self?.detailsView.refreshLabels()
//            self?.attributesTableView.reloadData()
        }
        
        addNewAttributeAlert.addAction(saveNewAttributeButton)
        
        saveButtonInAlertChanged = saveNewAttributeButton
        saveNewAttributeButton.isEnabled = false
    }
    
    private func updateAfterAddingAttr() {
        self.attributesArray = self.comparisonItemModel?.comparison?.attributesArray ?? []
        print(String(self.attributesArray.count), "ATTRS ARRAY COUNT AFTER UPDATE")
        self.attributesTableView.reloadData()
        self.detailsView.refreshLabels()
    }

    
    @objc private func textFieldChanged(_ sender: Any) {
        let textfield = sender as! UITextField
        guard let textfieldText = textfield.text else { return }
        let comparisonAttributesNames: [String] = comparisonItemModel?.comparison?.attributesArray.map {
            $0.unwrappedName
        } ?? []
        self.saveButtonInAlertChanged?.isEnabled = !textfieldText.trimmingCharacters(in: .whitespaces).isEmpty && !comparisonAttributesNames.contains(textfieldText)
    }
}

//MARK: deleteItemAlertConfiguration
//extension ObjectDetailsViewController {
//    private func deleteItemAlertConfiguration() {
//        
//        let itemName = self.comparisonItemModel?.unwrappedName ?? ""
//        self.deleteItemAlert = UIAlertController(title: "Are you shure?", message: " \(itemName) will be exterminate 💥", preferredStyle: .alert)
//        
//        let cancelDeletingButton = UIAlertAction(title: "Cancel", style: .cancel)
//        
//        
//        self.deleteItemAlert!.addAction(cancelDeletingButton)
//        
//        let deletingConfirmationButton = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
//            
//            self?.sharedDataBase.deleteComparisonItem(item: self?.comparisonItemModel ?? ComparisonItemEntity())
//            self?.dismiss(animated: true)
//        }
//        
//        self.deleteItemAlert!.addAction(deletingConfirmationButton)
//        
//        
//    }
//    
//
//}


extension ObjectDetailsViewController: UITextFieldDelegate {
}

//MARK: Getting data model from another view
extension ObjectDetailsViewController {

    
    public func setForNewItem(comparisonID: String, needUpdateViewController: Bool) {
        
        needUpdate = needUpdateViewController
        isNewItem = true
        guard let comparison = sharedDataBase.fetchComparisonWithID(id: comparisonID) else { return }
        comparisonModel = comparison
        detailsView.configureForNewItem(comparisonEntity: comparison)
        
//        detailsView.detailsViewDelegate = self
        configureBlurArea()
        configureBlureAreaLabel()
    }
    
    
    public func setForExistingItem(comparisonItem: ComparisonItemEntity) {
        isNewItem = false
        comparisonItemModel = comparisonItem
        comparisonModel = comparisonItem.comparison
//        let attrsSet = comparisonItem.attributes as? Set<ComparisonAttributeEntity>
//        let attrsArray = attrsSet?.sorted {$0.unwrappedDate > $1.unwrappedDate} ?? []
//        let attrs = comparisonItem.attributes
        attributesArray = comparisonItem.comparison?.attributesArray ?? []
        
        print(attributesArray.count, comparisonItemModel?.unwrappedName ?? "nil")
        detailsView.configureForExistedItem(comparisonItem: comparisonItem)
        
//        detailsView.detailsViewDelegate = self
    }
}


//MARK: configureBlurArea

extension ObjectDetailsViewController {
    func configureBlurArea() {
        view.addSubview(blurInactiveArea)
        view.addSubview(blureAreaLabel)

        
        let blurEffect = UIBlurEffect(style: .regular)
        blurInactiveArea.effect = blurEffect
        blurInactiveArea.alpha = 0.7
        
        
        let coveredConstraint = blurInactiveArea.topAnchor.constraint(equalTo: detailsView.bottomAnchor)
        coveredConstraint.isActive = true
        
        
        blurInactiveArea.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurInactiveArea.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blurInactiveArea.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        blureAreaLabel.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.bounds.height / 4)).isActive = true
        blureAreaLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    func configureBlureAreaLabel() {
        blureAreaLabel.textColor = .clear //UIColor(named: detailsView.itemColorName ?? UIColor.black.accessibilityName)
        blureAreaLabel.alpha = 1
    }
}

//MARK: Saving item
extension ObjectDetailsViewController {
    private func saveNewItem(name: String, comparisonEntity: ComparisonEntity, color: String) {
        comparisonModel = comparisonEntity
        let currentColor = color
        
        if sharedDataBase.createComparisonItem(name: name, relatedComparison: comparisonModel ?? ComparisonEntity(), color: currentColor) {
            print("Item created")
        } else {
            print("Item NOT created")
            return
        }
    }
    
    private func updateExistingItem(comparisonItem: ComparisonItemEntity, newName: String) {
        if sharedDataBase.updateComparisonItemName(for: comparisonItem, newName: newName) {
            print("Item updated")
        } else {
            print ("Updating failed")
            return
        }
    }
    
}

//MARK: -Set delegates
extension ObjectDetailsViewController {
    private func setDelegates() {
        attributesTableView.delegate = self
        attributesTableView.dataSource = self
        attributesTableView.register(AttributesTableViewCell.self, forCellReuseIdentifier: AttributesTableViewCell.idAttributeTableViewCell)
        
        draggableViewControllerDelegate = self

        detailsView.detailsViewDelegate = self
        
    }
}

//MARK: UITableViewDataSource
extension ObjectDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        attributesArray.count
        }
    
    func tableView(_ tableView: UITableView, 
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = attributesTableView.dequeueReusableCell(withIdentifier: 
                                                                    AttributesTableViewCell.idAttributeTableViewCell,
                                                                 for:
                                                                    indexPath) as? AttributesTableViewCell 
        else {
            return UITableViewCell()
        }
        
        let attribute = attributesArray[indexPath.row]
        let attributeName = attribute.unwrappedName
        let item = comparisonItemModel ?? ComparisonItemEntity()
        let cellValue = sharedDataBase.fetchValue(item: item, 
                                                  attribute: attribute)
        
        cell.updateButtonTitle(isValueTrue: cellValue.booleanValue)
        cell.updateAttributeName(name: attributeName)

        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        
        cell.delegate = self
        return cell
    }
}

extension ObjectDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        45
    }
    
}

//extension ObjectDetailsViewController {
//    private func creatingIsComplete(comparisonEntity: ComparisonEntity) {
//
//    }
//}


extension ObjectDetailsViewController: attributesTableViewCellDelegate {
    func contextMenuInteractionWasCalled(cell: UITableViewCell, indexPath: IndexPath) {
        
    }
    
    
    func didTapValueButton(cell: AttributesTableViewCell) {
        
        if let indexPath = attributesTableView.indexPath(for: cell) {
            let attribute = attributesArray[indexPath.row]
            let value = sharedDataBase.fetchValue(item: comparisonItemModel ?? ComparisonItemEntity(), attribute: attribute)
            sharedDataBase.changeBooleanValue(for: value)
            self.attributesTableView.reloadRows(at: [indexPath], with: .fade)
        }
        self.detailsView.refreshLabels()
    }
    
}



extension ObjectDetailsViewController: DetailsViewProtocol {
    func itemNameDidChanged(newName: String) {
        
        let comparisonEntity = comparisonModel ?? ComparisonEntity()
//        print(comparisonEntity.unwrappedName)
                
        guard let comparisonItem = comparisonItemModel else { return }
        let currentItemName = comparisonItem.unwrappedName
//        print("currentName = \(currentItemName)")
        
        let newItemName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
//        print("newItemName: \(newItemName)")
        
        let namesArray: [String] = comparisonEntity.itemsArray.map { $0.unwrappedName }
//        print("namesArray \(namesArray)")

        let nameIsFree = !namesArray.contains(newItemName)
        
        if newItemName.containsCharacters() && nameIsFree && newItemName != currentItemName {
//            print("Name \" \(newItemName) \" is avaliable")
            
            sharedDataBase.updateComparisonItemName(for: comparisonItem, newName: newItemName)
        } else {
            print("Name unavaliable")
        }
    }
    
    func itemNameDidSet(name: String) {
        
        let compariosnEntity = comparisonModel ?? ComparisonEntity()
        let color = detailsView.itemColorName ?? "sixGreenMagicMint"
        
        if isNewItem && name != "" {
            sharedDataBase.createComparisonItem(name: name, relatedComparison: compariosnEntity, color: color) { [weak self] _ in
//                self.blureAreaLabel.delete(self)
//                self.blurInactiveArea.delete(self)
                
                UIView.animate(withDuration: 0.3) {
                    self?.blureAreaLabel.alpha = 0
                    self?.blurInactiveArea.alpha = 0
                }
                
                
                
                let item = self?.sharedDataBase.fetchComparisonItemWithName(name: name, relatedComparison: compariosnEntity)
                
                self?.isNewItem = false
                self?.comparisonItemModel = item
                self?.detailsView.configureForExistedItem(comparisonItem: item ?? ComparisonItemEntity())
                
                self?.attributesArray = compariosnEntity.attributesArray
                self?.attributesTableView.reloadData()
                
                print("ITEM IS CREATED")
                print("ItemNamedidSet finished. ComparisonEntity: \(compariosnEntity.unwrappedName), Item`sComparison:\(item?.comparison?.unwrappedName ?? "nil")")

            }
        } else if !isNewItem {
            print("ODVC CLOSED WITH EXISTED ITEM")
        }
        
    }
    
    
}


//MARK: - ContextMenu for AttributesTableViewCell
extension ObjectDetailsViewController: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = interaction.view as? AttributesTableViewCell,
              let indexPath = self.attributesTableView.indexPath(for: cell) else { return nil }
        let identifier = indexPath.row
        
        attributesTableView.clipsToBounds = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.attributesTableView.clipsToBounds = true
        }
        
        return UIContextMenuConfiguration(identifier: identifier as NSCopying) {
            return nil
        } actionProvider: { _ in
            self.attributesTableView.clipsToBounds = true
            
            let changinngAttribute = self.attributesArray[indexPath.row]
            
            let changeNameAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [weak self] action in
                
                guard let self = self else { return }
                
                self.alertConfigurationForAttributeChangeName(attribute: changinngAttribute)
                
                present(self.attributeChangeNameAlert ?? UIAlertController(), animated: true) { [weak self] in
                    guard let self = self else { return }
                    
                    let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAttributeChangeNameAlert))
                    
                    self.attributeChangeNameAlert?.view.window?.isUserInteractionEnabled = true
                    self.attributeChangeNameAlert?.view.superview?.subviews[0].addGestureRecognizer(dismissGesture)
                }
                print("rename attribute tapped \(changinngAttribute.unwrappedName)")
            }
            
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, attributes: .destructive) { action in
                let delay = 0.4
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.sharedData.deleteComparisonAttribute(attribute: changinngAttribute)
                }
                
                
                self.attributesArray.remove(at: indexPath.row)
//                self.attributesTableView.deleteRows(at: [indexPath], with: .right)
                self.attributesTableView.reloadData()
                print("deleteAction tapped \(changinngAttribute.unwrappedName)")
            }
            
            
            return UIMenu(title:"",
                          children: [ changeNameAction,
                                      deleteAction ]
            )
        }

    }
    
    @objc func dismissAttributeChangeNameAlert() {
        self.attributeChangeNameAlert?.dismiss(animated: true)
        self.attributeChangeNameAlert?.view.window?.removeGestureRecognizer(dismissAttributeChangeNameAlertGesture)
    }
    
    
    func alertConfigurationForAttributeChangeName(attribute: ComparisonAttributeEntity) {
        
        self.attributeChangeNameAlert = UIAlertController(title: "Edit attibute", message: "", preferredStyle: .alert)
        
        attributeChangeNameAlert?.addTextField { textfield in
            textfield.delegate = self
            textfield.autocapitalizationType = .sentences
            textfield.clearButtonMode = .always
            textfield.text = attribute.unwrappedName
            textfield.placeholder = "\(attribute.unwrappedName)"
            textfield.addTarget(self, action: #selector(self.textfieldChanged), for: .editingChanged)
        }
        
        let saveAttirbuteNameAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak attributeChangeNameAlert] (_) in
            guard let self = self else { return }
            let textfieldText = attributeChangeNameAlert?.textFields?[0].text ?? "NoText"
            let savingResult = self.sharedData.updateComparisonAttributeName(for: attribute, newName: textfieldText)
            
            
            if savingResult == false {
                print("comparison doesn`t changed")
            } else {
                self.attributesTableView.reloadData()
                print("attribute name -\(textfieldText)- saved")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.attributeChangeNameAlert?.view.window?.removeGestureRecognizer(self.dismissAttributeChangeNameAlertGesture)
            self.attributeChangeNameAlert?.dismiss(animated: true) {
                self.attributeChangeNameAlert?.view.window?.removeGestureRecognizer(self.dismissAttributeChangeNameAlertGesture)
            }
            self.attributeChangeNameAlert = UIAlertController()
        }
        attributeChangeNameAlert?.addAction(saveAttirbuteNameAction)
        attributeChangeNameAlert?.addAction(cancelAction)
        saveAttributeButtonInAlertChanged = saveAttirbuteNameAction
        saveAttirbuteNameAction.isEnabled = false
        
    }
   
    @objc func textfieldChanged(_ sender: Any) {
        let textfield = sender as! UITextField
        guard let textfieldText = textfield.text else { return }
        
        let attrs = self.attributesArray
        
        let attrsNames: [String] = attrs.map { $0.unwrappedName }
        
        self.saveAttributeButtonInAlertChanged?.isEnabled = !textfieldText.trimmingCharacters(in: .whitespaces).isEmpty && !attrsNames.contains(textfieldText)
    }
    
}

