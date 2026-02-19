//
//  DeleteItemButton.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 06.04.2023.
//

import UIKit

class DeleteItemButton: UIButton {
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
        layer.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .specialColors.subviewBackground
        titleLabel?.font = .sfProTextRegular16()
//        titleLabel?.textColor = .red
        titleLabel?.text = "Delete item"
        tintColor = .red
    }
}
