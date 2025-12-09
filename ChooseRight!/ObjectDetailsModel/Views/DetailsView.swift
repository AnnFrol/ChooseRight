//
//  DetailsView.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 03.04.2023.
//

import UIKit

protocol DetailsViewProtocol: AnyObject {
    func saveDetails(itemName: String)
    func setupDetailsView(comparisonItem: String)
}

class DetailsView: UIView {
    
    private var comparisonItemName = String()

    weak var detailsViewDelegate: DetailsViewProtocol?
    
    private var comparisonModel = ComparisonEntity()
    private var itemModel = ComparisonItemEntity()
    
//    private var comparisonName: String = "ChooseRight"
    private var comparisonPluses: Int = 0
    private var comparisonMinuses: Int = 0
//    private var comparisonScore: Int = { 0 }()
    private var comparisonRelevance: Int = { 0 }()
    
    private let comparisonNameLabel = UILabel(detailsSecondaryLabelText: "Choose Right")
    public let newItemTextField = NewItemTextField()
    private var textFieldStackView = UIStackView()
    
    private let relevanceLabel = UILabel(detailsSecondaryLabelText: "Relevance")
    private let relevanceValueLabel = UILabel(detailsRelevanseValueLabelText: "0%")
    private var relevanceStackview = UIStackView()
    
    private let scoreLabel = UILabel(detailsSecondaryLabelText: "Score")
    private let scoreValueLabel = UILabel(detailsScoreValueLabelText: "0/0")
    private var scoreStackView = UIStackView()
    
    private var bottomStackView = UIStackView()
    
    private func setupViews() {
        backgroundColor = .specialColors.sixGreenMagicMint
        scoreLabel.textAlignment = .right
        translatesAutoresizingMaskIntoConstraints = false
        
        textFieldStackView = UIStackView(arrangedSubviews: [comparisonNameLabel,
                                                           newItemTextField],
                                         axis: .vertical,
                                         spacing: 8)
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.distribution = .equalCentering
        addSubview(textFieldStackView)
        
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
        comparisonModel = comparisonEntity
//        comparisonScore = 75
        comparisonPluses = 3
        comparisonMinuses = 1
        comparisonRelevance = 75
        
        newItemTextField.delegate = self
        newItemTextField.addTarget(self, action: #selector(self.setTextfieldKern), for: .allEditingEvents)
        newItemTextField.text = ""
        
        comparisonNameLabel.text = comparisonEntity.unwrappedName//itemModel.comparison?.unwrappedName
        relevanceValueLabel.text = "\(comparisonRelevance)%"
        scoreValueLabel.text = "\(comparisonPluses)/\(comparisonMinuses)"
    }
    
    public func configureForExistedItem(comparisonItem: ComparisonItemEntity) {
        newItemTextField.delegate = self
        newItemTextField.addTarget(self, action: #selector(self.setTextfieldKern), for: .allEditingEvents)
        itemModel = comparisonItem
        comparisonNameLabel.text = comparisonItem.comparison?.unwrappedName
//        newItemTextField.text = comparisonItem.unwrappedName
        newItemTextField.attributedText = NSMutableAttributedString(string: comparisonItem.unwrappedName,
                                                                    attributes:
                                                                       [NSAttributedString.Key.kern: -1.37])
    }
    
//    public func savingData() {
//        
//    }
    
}

extension DetailsView {
    private func setConstraints() {
        NSLayoutConstraint.activate([
        
            textFieldStackView.topAnchor.constraint(equalTo: topAnchor, constant: 55),
            textFieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textFieldStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.212),
            textFieldStackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
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


extension DetailsView: UITextFieldDelegate {
    @objc private func setTextfieldKern(_ sender: Any) {
        let textfield = sender as! UITextField
        guard let textfieldText = textfield.text else { return }
        textfield.attributedText = NSMutableAttributedString(string: textfieldText,
                                                             attributes:
                                                                [NSAttributedString.Key.kern: -1.37])
    }
}
