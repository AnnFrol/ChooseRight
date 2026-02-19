//
//  AttributesTableViewCell.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 04.04.2023.
//

import UIKit

protocol attributesTableViewCellDelegate: AnyObject {
    func didTapValueButton(cell: AttributesTableViewCell)
    func contextMenuInteractionWasCalled(cell: UITableViewCell, indexPath: IndexPath)
}

class AttributesTableViewCell: UITableViewCell {
    
    weak var delegate: attributesTableViewCellDelegate?
    
    private let attributeNameLabel = UILabel(attributeLabelText: "Expences")

    private lazy var attributeValueButton: PlusMinusButton = {
        let button = PlusMinusButton(type: .system)
        button.titleLabel?.font = .sfProTextRegular23()
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
        layer.cornerRadius = 10
        backgroundColor = .specialColors.background
        clipsToBounds = false

        attributeValueButton.addTarget(self, 
                                       action: #selector(buttonTapped),
                                       for: .touchUpInside)
        
        cellStackView = UIStackView(arrangedSubviews: [attributeNameLabel,
                                                       attributeValueButton],
                                    axis: .horizontal,
                                    spacing: 30)
        
        cellStackView.distribution = .equalSpacing
        cellStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellStackView)
    }

    @objc private func buttonTapped() {
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        self.delegate?.didTapValueButton(cell: self)
    }
    
    
    func updateButtonTitle(isValueTrue: Bool) {
        self.attributeValueButton.updateTitle(isValueTrue: isValueTrue)
    }
    
    func updateAttributeName(name: String) {
        attributeNameLabel.text = name
    }
}

extension AttributesTableViewCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([

            cellStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            cellStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant:  10),
            cellStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            cellStackView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: 0),

            attributeValueButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
}



