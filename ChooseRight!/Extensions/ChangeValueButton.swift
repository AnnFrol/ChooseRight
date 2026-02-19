//
//  ChangeValueButton.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 07.04.2023.
//

import UIKit

class ChangeValueButton: UIButton {
    
    private var font = UIFont.systemFont(ofSize: 20)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init(title: String, font: UIFont = UIFont.sfProTextRegular23() ?? UIFont.systemFont(ofSize: 23)) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        titleLabel?.font = font
        
        configure()
    }
    private func configure() {
        backgroundColor = .clear
        
        translatesAutoresizingMaskIntoConstraints = false
        tintColor = .specialColors.detailsOptionTableText
        titleColor(for: .normal)
        titleLabel?.font = .sfProTextRegular23()
        titleLabel?.alpha = 0.6
//        alpha = 0.6
        titleLabel?.text = "Button"
    }
}
