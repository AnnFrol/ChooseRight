//
//  AttributesTableViewCell.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 04.04.2023.
//

import UIKit

class AttributesTableViewCell: UITableViewCell {
    
    private var attributesArray = [ComparisonAttributeEntity]()

    private let attributeNameLabel = UILabel(attributeLabelText: "Expences")
//    private let attributeValueLabel = UILabel(detailsTableValueLabel: "+")
//    private let attributeValueButton = ChangeValueButton(title: " + ")
    private lazy var attributeValueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.titleEdgeInsets = .init(top: 0, left: 40, bottom: 0, right: 0)
        button.tintColor = .specialColors.text
        button.titleLabel?.font = .sfProTextRegular23()
        button.alpha = 0.6
        return button
    }() 

    private var cellStackView = UIStackView()

    static let idAttributeTableViewCell = "idAttributeTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear

        attributeValueButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        cellStackView = UIStackView(arrangedSubviews: [attributeNameLabel,
//                                                       attributeValueLabel,
                                                       attributeValueButton
                                                      ],
                                    axis: .horizontal,
                                    spacing: 140)
        cellStackView.distribution = .equalSpacing
        cellStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellStackView)
    }
    
    public func configure(comparisonAttribute: ComparisonAttributeEntity) {
        
//        attributeNameLabel
    }

    @objc private func buttonTapped() {
        if attributeValueButton.titleLabel?.text == "+" {
            attributeValueButton.setTitle("-", for: .normal)
            print(attributeValueButton.titleLabel?.text as Any)
        } else {
            attributeValueButton.setTitle("+", for: .normal)
            print(attributeValueButton.titleLabel?.text as Any)
        }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}


extension AttributesTableViewCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([

            cellStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            cellStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant:  0),
            cellStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            cellStackView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: 0),

            attributeValueButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}


