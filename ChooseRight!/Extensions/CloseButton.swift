//
//  CloseButton.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 02.04.2023.
//

import UIKit

class CloseButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        // Всегда тёмная иконка и на светлой, и на тёмной теме
        tintColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityLabel = NSLocalizedString("Close", comment: "Accessibility: close button")
        accessibilityHint = NSLocalizedString("Double tap to close.", comment: "Accessibility: close button hint")
    }    
}
