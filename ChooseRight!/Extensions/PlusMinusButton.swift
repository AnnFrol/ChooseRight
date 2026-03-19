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
        setTitle(nil, for: .normal)
        setImage(nil, for: .normal)
        titleLabel?.font = .sfProTextRegular23()
        alpha = 0.6
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }
    
    func updateTitle(state: ComparisonValueState) {
        setImage(nil, for: .normal)
        setTitle(nil, for: .normal)
        
        switch state {
        case .plus, .minus:
            setTitle(state.displaySymbol, for: .normal)
        case .neutral:
            setImage(UIImage(named: "neutralCircle")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        accessibilityLabel = state.accessibilityLabel
    }
}
