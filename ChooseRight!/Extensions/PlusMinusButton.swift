//
//  PlusMinusButton.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 08.01.2024.
//

import UIKit

class PlusMinusButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        tintColor = .specialColors.text
//        titleLabel?.font = .sfProTextRegular23()
        setTitle(" ", for: .normal)
        titleLabel?.font = .sfProTextRegular23()
        alpha = 0.6
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
    
    func updateTitle(isValueTrue: Bool) {
        let title = isValueTrue ? "+" : "-"
        setTitle(title, for: .normal)
    }
}
