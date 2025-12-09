//
//  MainCollectionViewCell.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 11.06.2023.
//

import Foundation
import UIKit

class ValuesCollectionViewCell: UICollectionViewCell {
    
    static let idValuesColectionViewCell = "idValuesColectionViewCell"
    
//    public lazy var attributeValueButton1: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("+", for: .normal)
//        button.layer.cornerRadius = 10
//        button.backgroundColor = .clear
//        button.translatesAutoresizingMaskIntoConstraints = false
////        button.titleEdgeInsets = .init(top: 0, left: 40, bottom: 0, right: 0)
//        button.tintColor = .specialTextColor
//        button.titleLabel?.font = .sfProTextRegular23()
//        button.alpha = 0.6
//        return button
//    }()
    
//    public let attributeValueLabel: UILabel = {
//       let label = UILabel()
//        label.text = "+"
//        label.textColor = .black
//        label.font = .systemFont(ofSize: 14)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let background: UIView = {
//        let view = UIView()
//        view.isUserInteractionEnabled = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1394325818)
//
//        return view
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        setupView()
//        setConstraints()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupView() {
//
//        layer.cornerRadius = 10
//        backgroundColor = .green
////        translatesAutoresizingMaskIntoConstraints = false
//
//        addSubview(background)
//        addSubview(attributeValueLabel)
//    }
//}
//
//extension ValuesCollectionViewCell {
//    private func setConstraints() {
//        NSLayoutConstraint.activate([
//
//            attributeValueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            attributeValueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
//
//            background.topAnchor.constraint(equalTo: topAnchor),
//            background.leadingAnchor.constraint(equalTo: leadingAnchor),
//            background.trailingAnchor.constraint(equalTo: trailingAnchor),
//            background.bottomAnchor.constraint(equalTo: bottomAnchor)
//
////            label.centerXAnchor.constraint(equalTo: centerXAnchor),
////            label.centerYAnchor.constraint(equalTo: centerYAnchor),
//        ])
//    }
//}

    public var attributeLabel = UILabel(attributeLabelText: "Text")
    
    
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
        attributeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .clear
        addSubview(attributeLabel)
    }
}

extension ValuesCollectionViewCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
//            attributeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            attributeLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            attributeLabel.topAnchor.constraint(equalTo: topAnchor),
            attributeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            attributeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            attributeLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
