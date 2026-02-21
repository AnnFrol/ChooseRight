//
//  AddAttributeButton.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 06.04.2023.
//

import UIKit

class AddAttributeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        configure()
    }
    
    private func configure() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .specialColors.detailsOptionTableText
        titleLabel?.font = .sfProTextRegular14()
        alpha = 0.6
        titleLabel?.textAlignment = .right
    }
}
