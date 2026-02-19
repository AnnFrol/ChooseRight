//
//  DetailsView.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 03.04.2023.
//

import UIKit

protocol DetailsViewProtocol: AnyObject {
//    func saveDetails(itemName: String)
//    func setupDetailsView(comparisonItem: String)
    func itemNameDidSet(name: String)
    func itemNameDidChanged(newName: String)
    
}

class DetailsView: UIView {
    
    private var comparisonItemName = String()

    weak var detailsViewDelegate: DetailsViewProtocol?
    
    private var comparisonEntity = ComparisonEntity()
    private var itemEntity = ComparisonItemEntity()
    
//    private var comparisonName: String = "ChooseRight"
    private var comparisonPluses: Int = 0
    private var comparisonMinuses: Int = 0
//    private var comparisonScore: Int = { 0 }()
    private var comparisonRelevance: Int = { 0 }()
    
    private let comparisonNameLabel = UILabel(detailsSecondaryLabelText: "Choose Right")
    public let newItemTextField = NewItemTextField()
    private var textFieldStackView = UIStackView()
    
    
    private let attentionLabel: UILabel = {
       let label = UILabel()
        label.text = "Name exists!"
        label.textColor = UIColor.specialColors.detailsMainLabelText
        label.font = UIFont(name: "SFProDisplay-Regular", size: 15)
        label.alpha = 0.4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let attentionImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "exclamationmark.triangle.fill")?.withTintColor(.specialColors.detailsMainLabelText ?? .lightText, renderingMode: .alwaysOriginal)
        view.alpha = 0.4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
//    private let attentionImage: UILabel = {
//        let view = UILabel()
//        view.text = "\(UIImage(exclamationmark.triangle.fill)"
////        view.image = UIImage(named: "exclamationmark.triangle.fill")?.withTintColor(.specialColors.detailsMainLabelText ?? .lightText, renderingMode: .alwaysOriginal)
//        view.alpha = 0.4
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    private var attentionStackView = UIStackView()
    
    
    private let relevanceLabel = UILabel(detailsSecondaryLabelText: "Relevance")
    private let relevanceValueLabel = UILabel(detailsRelevanseValueLabelText: "0%")
    private var relevanceStackview = UIStackView()
    
    private let scoreLabel = UILabel(detailsSecondaryLabelText: "Score")
    private let scoreValueLabel = UILabel(detailsScoreValueLabelText: "0/0")
    private var scoreStackView = UIStackView()
    
    private var bottomStackView = UIStackView()
    
    var itemColorName = specialColors.first
    
    private func setupViews() {
        backgroundColor = UIColor(named: itemColorName ?? "sixGreenMagicMint")
        scoreLabel.textAlignment = .right
        translatesAutoresizingMaskIntoConstraints = false
        
        textFieldStackView = UIStackView(arrangedSubviews: [comparisonNameLabel,
                                                           newItemTextField],
                                         axis: .vertical,
                                         spacing: 8)
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.distribution = .equalCentering
        addSubview(textFieldStackView)
        
        
        attentionStackView = UIStackView(arrangedSubviews: [attentionImage,
                                                           attentionLabel],
                                         axis: .horizontal,
                                         spacing: 4)
        attentionStackView.translatesAutoresizingMaskIntoConstraints = false
        attentionStackView.alpha = 0
        addSubview(attentionStackView)
        
        
        relevanceStackview = UIStackView(arrangedSubviews: [relevanceLabel,
                                                           relevanceValueLabel],
                                         axis: .vertical,
                                         spacing: 0)
        relevanceStackview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(relevanceStackview)
        
        
        scoreStackView = UIStackView(arrangedSubviews: [scoreLabel,
                                                       scoreValueLabel],
                                     axis: .vertical,
                                     spacing: 4)
        scoreStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scoreStackView)
        
        newItemTextField.addTarget(self, action: #selector(self.setTextfieldKern), for: .allEditingEvents)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public func setItemEntity(itemEntity: ComparisonItemEntity) {
//        itemModel = itemEntity
//    }
    
    public func configureForNewItem(comparisonEntity: ComparisonEntity) {
        self.comparisonEntity = comparisonEntity
        
        switch comparisonEntity.itemsArray.count {
        case 0: itemColorName = specialColors[0]
            
        case 1...:
            
            let lastColor = comparisonEntity.itemsArray.first?.color ?? specialColors[0]
            let currentColorIndex = specialColors.firstIndex(of: lastColor)
            itemColorName = specialColors[(currentColorIndex! + 1) % specialColors.count]
        default:
            itemColorName = specialColors.first
        }
        
//        comparisonScore = 75
//        comparisonPluses = 0
//        comparisonMinuses = 0
//        comparisonRelevance = 0
        
        newItemTextField.delegate = self
        newItemTextField.text = ""
        newItemTextField.returnKeyType = .done
        
        newItemTextField.addTarget(self, action: #selector(textfieldEditingDidEnd), for: .editingDidEnd)
        
        comparisonNameLabel.text = comparisonEntity.unwrappedName//itemModel.comparison?.unwrappedName
        relevanceValueLabel.text = "\(comparisonRelevance)%"
        scoreValueLabel.text = "\(comparisonPluses)/\(comparisonMinuses)"
        
        newItemTextField.addTarget(self, action: #selector(isNameForNewItemExists), for: .editingChanged)
        
        
        backgroundColor = UIColor(named: itemColorName ?? "sixGreenMagicMint")
    }
    
    @objc private func textfieldEditingDidEnd() {
        let itemName = newItemTextField.text ?? ""
        
        detailsViewDelegate?.itemNameDidSet(name: itemName)        
    }
    
    public func configureForExistedItem(comparisonItem: ComparisonItemEntity) {
        newItemTextField.delegate = self
        newItemTextField.returnKeyType = .done
        
        newItemTextField.addTarget(self, action: #selector(isNameUsedForExist), for: .editingChanged)
        
        newItemTextField.addTarget(self, action: #selector(saveNewNameForExist), for: .editingDidEnd)
        
        itemEntity = comparisonItem
        comparisonEntity = comparisonItem.comparison ?? ComparisonEntity()
        backgroundColor = UIColor(named: itemEntity.color ?? "sixGreenMagicMint")
        comparisonNameLabel.text = comparisonItem.comparison?.unwrappedName
        
        comparisonRelevance = itemEntity.getRelevance
        relevanceValueLabel.attributedText = NSMutableAttributedString(string: "\(comparisonRelevance)%", attributes: [NSAttributedString.Key.kern: -4])
        let plusesMinuses = itemEntity.getPlusesAndValues
        scoreValueLabel.text = "\(plusesMinuses[0])/\(plusesMinuses[1])"
        
        newItemTextField.attributedText = NSMutableAttributedString(string: comparisonItem.unwrappedName,
                                                                    attributes:
                                                                       [NSAttributedString.Key.kern: -1.37])
    }
    
    @objc func saveNewNameForExist(){
        
        let actualName = itemEntity.unwrappedName
        let newItemName = newItemTextField.text ?? ""
        
        if actualName != newItemName {
            
            detailsViewDelegate?.itemNameDidChanged(newName: newItemName)
        }
    }
    
    
    public func refreshLabels() {
        let plusesMinuses = itemEntity.getPlusesAndValues
        let relevance = itemEntity.getRelevance
        
        UIView.animate(withDuration: 0.2) {
//            self.relevanceValueLabel.transform = .init(scaleX: 0.9, y: 0.9)
            self.relevanceValueLabel.alpha = 0.2
            
        } completion: { Bool in
            
            self.scoreValueLabel.text = "\(plusesMinuses[0])/\(plusesMinuses[1])"
            UIView.animate(withDuration: 0.1
            ) {
                self.relevanceValueLabel.alpha = 1
                self.relevanceValueLabel.attributedText = NSAttributedString(string: "\(relevance)%", attributes:           [NSAttributedString.Key.kern: -4])
//                self.relevanceValueLabel.transform = .identity
            }
        }
    }
}


extension DetailsView {
    private func setConstraints() {
        NSLayoutConstraint.activate([
        
            textFieldStackView.topAnchor.constraint(equalTo: topAnchor, constant: 55),
            textFieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textFieldStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.212),
            textFieldStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            attentionStackView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 3),
            attentionStackView.leadingAnchor.constraint(equalTo: textFieldStackView.leadingAnchor),
            
            newItemTextField.heightAnchor.constraint(equalToConstant: 40),
            newItemTextField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            relevanceStackview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            relevanceStackview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            relevanceStackview.heightAnchor.constraint(equalToConstant: 110),
            
            scoreStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            scoreStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -35),
            scoreStackView.heightAnchor.constraint(equalToConstant: 62)
        ])
    }
}



//MARK: Textfield
extension DetailsView: UITextFieldDelegate {
    @objc private func setTextfieldKern(_ sender: Any) {
        let textfield = sender as! UITextField
        guard let textfieldText = textfield.text else { return }
        textfield.attributedText = NSMutableAttributedString(string: textfieldText,
                                                             attributes:
                                                                [NSAttributedString.Key.kern: -1.37])
    }
    
    @objc private func isNameUsedForExist(_ sender: Any) {
        let actualName = itemEntity.unwrappedName
        let textfield = sender as! UITextField
        let namesArray: [String] = comparisonEntity.itemsArray.map { $0.unwrappedName }
        guard let textfieldText = textfield.text else { return }
        
        let isNameUsed = namesArray.contains(textfieldText) && textfieldText != actualName
        
        
        
        attentionStackView.alpha = isNameUsed ? 1 : 0
        
    }
    
    @objc private func isNameForNewItemExists(_ sender: Any) {
        
        let textfield = sender as! UITextField
        let namesArray: [String] = comparisonEntity.itemsArray.map { $0.unwrappedName }
        guard let textfieldText = textfield.text else { return }
        
        let isNameUsed = namesArray.contains(textfieldText)
        
        attentionStackView.alpha = isNameUsed ? 1 : 0
        
    }
}
