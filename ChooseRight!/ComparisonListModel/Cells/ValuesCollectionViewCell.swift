//
//  MainCollectionViewCell.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 11.06.2023.
//

import Foundation
import UIKit

protocol valuesCollectionViewCellDelegate: AnyObject {
    func didTapValueButton(cell: ValuesCollectionViewCell)
}

class ValuesCollectionViewCell: UICollectionViewCell {
        
    weak var delegate: valuesCollectionViewCellDelegate?
    
    static let idValuesColectionViewCell = "idValuesColectionViewCell"
    
    private lazy var valueButton: PlusMinusButton = {
        let button = PlusMinusButton(type: .system)
        button.titleLabel?.font = .sfProTextRegular20()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        valueButton.addTarget(self, action: #selector(valueButtonTapped), for: .touchUpInside)
        addSubview(valueButton)
    }
    
    @objc private func valueButtonTapped() {
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        self.delegate?.didTapValueButton(cell: self)
    }
    
    public func updateButtonTitle(isValueTrue: Bool) {
        self.valueButton.updateTitle(isValueTrue: isValueTrue)
    }
}

extension ValuesCollectionViewCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
            valueButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
