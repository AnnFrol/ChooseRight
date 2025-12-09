//
//  MainViewController.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 23.04.2023.
//

import Foundation
import UIKit
import CoreData

class MainViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    var dismissGesture = UITapGestureRecognizer()
    
    let notchView: UILabel = {
        let label = UILabel()
        label.text = "    Choose Right!    "
        label.font = .sfProDisplaySemibold12()
        label.backgroundColor = .specialColors.threeBlueLavender
        label.textColor = .specialColors.detailsMainLabelText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        return label
    }()
    
    let warningMessageEmoji = ["😉", "💁‍♂️", "👻", "🙀", "🥈", "🚧", "❣️", "🥸", "👯", "🙃", "🧐", "🤓", "🤔"]
    
    weak var saveButtonInAlertChanged: UIAlertAction?
    
    let sharedDataBase = CoreDataManager.shared
    
    var settingsMenu = UIMenu()
    
    public var createNewComparisonListAlert:
    UIAlertController? = UIAlertController(
        title: "Create new comparison",
        message: "",
        preferredStyle: .alert)
    
    public var deleteComparisonConfirmationAlert:
    UIAlertController? = UIAlertController(
        title: "Delete comparison?",
        message: "",
        preferredStyle: .actionSheet)
    
    public var createNameChangingAlert:
    UIAlertController? = UIAlertController(
        title: "Rename your comparison",
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
    
    let placeholderArrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "MainViewPlaceholder")?.withTintColor(.specialColors.detailsOptionTableText ?? .lightText, renderingMode: .alwaysOriginal)
        view.alpha = 1
        //        view.tintColor = .specialColors.detailsOptionTableText
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var cellMenu = UIMenu()
    
    private let mainLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString(string: "Choose Right",
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
        let image = UIImage(named: "optionButton")
        button.setImage((image), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var titleStackView = UIStackView()
    
    lazy var addButton = AddButton()
    
    let tableView = MainTableView()
    
    private var bottomInset: Int = 120
    var insets = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
    
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
        
//        ScreenOrientationUtility.lockOrientation(.portrait)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        view.layoutIfNeeded()
//        UIView.animate(withDuration: 0.4) {
//            self.view.alpha = 1
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        
//        ScreenOrientationUtility.lockOrientation(.all)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setConstraints()
        setBottomInset()
        setDelegate()
        
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? "")
        
        if let constant = self.titleStackTopAnchor?.constant {
            print(constant, "mainLabelTop")
        }
        
        self.addButton.layer.cornerRadius = self.addButton.frame.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMenu), name: .didChangeTheme, object: nil)
        
        
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
        
        view.addSubview(placeholderArrowImageView)
        
        view.backgroundColor = .specialColors.background
        
        view.addSubview(tableView)
        
        view.addSubview(statusBarGradientView)
        
//        view.addSubview(mainLabel)
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        settingsButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        view.addSubview(addButton)
        
        view.addSubview(notchView)
        notchView.layer.cornerRadius = 8
        
        updateMenu()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
//        setupGradient()
    }
    
    @objc func showMenu(_ sender: UIButton) {
        
        print("menu pushed, themeIsLight \(ThemeManager.isLightTheme(for: view))")
        let menu = setupSettingsMenu()
        
        sender.menu = menu
        sender.showsMenuAsPrimaryAction = true
        print("menu pushed, func ended, themeIsLight \(ThemeManager.isLightTheme(for: view))")

    }
    
//    private func createSettingsMenu() {
//        let settingsMenu = setupSettingsMenu()
//        settingsButton.menu = settingsMenu
//        settingsButton.showsMenuAsPrimaryAction = true
//    }
    
    
    @objc func placeholderTapped() {
        self.addButton.animateButton(delay: 0)
    }
    
    private func addGestureToPlaceholder() {
        let tapToAnimateAddButton = UITapGestureRecognizer(target: self, action: #selector(placeholderTapped))
        self.placeholderLabel.addGestureRecognizer(tapToAnimateAddButton)
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
        titleStackTopAnchor = titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        
        tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 20)
        
        NSLayoutConstraint.activate([
            
            titleStackTopAnchor!,
            titleStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            titleStackView.heightAnchor.constraint(equalToConstant: 36),
            
//            mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            mainLabel.heightAnchor.constraint(equalToConstant: 36),
//            mainLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17),
            addButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.17),
            
            tableViewTopAnchor!,
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
//            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            
            placeholderLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            placeholderLabel.leadingAnchor.constraint(equalTo: mainLabel.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: mainLabel.trailingAnchor),
            placeholderLabel.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: mainLabel.bottomAnchor, multiplier: 25),
            
            placeholderArrowImageView.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 40),
            placeholderArrowImageView.bottomAnchor.constraint(equalTo: addButton.centerYAnchor),
            placeholderArrowImageView.leadingAnchor.constraint(equalTo: placeholderLabel.leadingAnchor, constant: 10),
            placeholderArrowImageView.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -40),
            
            statusBarGradientView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            statusBarGradientView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarGradientView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                   
            notchView.heightAnchor.constraint(equalToConstant: 15),
            notchView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notchView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15)
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
                self.placeholderArrowImageView.alpha = 1
            })
            
            self.addButton.animateButton(delay: 2)
            
        case 1...:

                self.placeholderLabel.alpha = 0
                self.placeholderArrowImageView.alpha = 0

        default:

                self.placeholderLabel.alpha = 0
                self.placeholderArrowImageView.alpha = 0

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

        
        let changeName = UIAction(title: "Change name", image: UIImage(systemName: "pencil")) {[self] _ in
//            let changingComparison = self.comparisonsArray[indexPath.section]
            self.alertConfigurationForChangeName(comparison: changingComparison)
            present(self.createNameChangingAlert ?? UIAlertController(), animated: true) { [weak self] in
                guard let self = self else { return }
                
                dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissChangeNameAlert))
                
                self.createNameChangingAlert?.view.window?.isUserInteractionEnabled = true
                
                self.createNameChangingAlert?.view.superview?.subviews[0].addGestureRecognizer(dismissGesture)
            }
            print(indexPath)
        }
        
        let changeColor = UIAction(title: "Change color", image: UIImage(systemName: "paintpalette")) { _ in
            
//            let changingComparison = self.comparisonsArray[indexPath.section]
            
            //next color
            guard let oldColor = changingComparison.color else {
                changingComparison.color = specialColors.first
                return
            }
            guard let oldColorIndex = specialColors.firstIndex(of: oldColor) else {
                changingComparison.color = specialColors.first
                return
            }
            
            let newColorIndex = (oldColorIndex + 1) % specialColors.count
//            changingComparison.color = specialColors[newColorIndex]
            let newColorName = specialColors[newColorIndex]
            self.sharedDataBase.updateComparisonColor(for: changingComparison, color: newColorName)
            
            self.tableView.reloadData()
        }

        let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { [self] _ in
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
    private func getData(){
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
        print("CompArrayCount:", comparisonsArray.count)
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
        bottomInset = Int(view.bounds.height * 0.17)
        insets.bottom = CGFloat(bottomInset)
        tableView.contentInset = insets
        print("Inset size \(bottomInset)")
    }
}


//MARK: - ComparisonTableViewCellTapped
extension MainViewController {
    private func cellTapped(comparison: ComparisonEntity) {
        
        print("cell tapped")
        
        let destination = ComparisonListViewController()
        destination.setComparisonEntity(comparison: comparison)
        notchView.alpha = 0
        navigationController?.pushViewController(destination, animation: true, completion: {
            destination.notchView.alpha = 1
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
}

