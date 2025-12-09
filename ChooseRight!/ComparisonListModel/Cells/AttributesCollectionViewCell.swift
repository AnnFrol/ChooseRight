//
//  AttributesCollectionViewCell.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 11.06.2023.
//

import Foundation
import UIKit

protocol DeleteAttributeCellProtocol {
    func deleteAttribute(index: IndexPath)
}

class AttributesCollectionViewCell: UICollectionViewCell {
    
    var deleteAttributeDelegate: DeleteAttributeCellProtocol?
    var index: IndexPath?
    
    static let idAttributesCollectionViewCell = "idAttributesCollectionViewCell"
    
    public var attributeLabel = UILabel(attributeLabelText: "Text")
    
    public var isEditing: Bool = false {
        didSet {
            deleteButton.isHidden = !isEditing
        }
        
    }
    
    lazy var deleteButton: UIButton = {
        let view = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        view.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        view.tintColor = .specialColors.detailsOptionTableText
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.7
        view.isHidden = !isEditing
        return view
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
        
//        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .clear
        clipsToBounds = false
        addSubview(attributeLabel)
        
        addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(deleteAttribute), for: .touchUpInside)
    }
    
    @objc private func deleteAttribute() {
        deleteAttributeDelegate?.deleteAttribute(index: index ?? IndexPath())
    }
}

extension AttributesCollectionViewCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
            attributeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            attributeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteButton.topAnchor.constraint(equalTo: topAnchor)
        ])    
    }
}
