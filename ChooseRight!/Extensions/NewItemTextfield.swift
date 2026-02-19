//
//  NewItemTextfield.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 04.04.2023.
//

import UIKit

class NewItemTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {

        borderStyle = .none
        textColor = .specialColors.detailsMainLabelText
        
        
        font = .sfProTextSemibold33()
        attributedPlaceholder = NSAttributedString(
            string: "New item",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.specialColors.plaseholder ?? .placeholderText])
        translatesAutoresizingMaskIntoConstraints = false
        attributedText = NSMutableAttributedString(string: "",
                                                                 attributes:
                                                                    [NSAttributedString.Key.kern: -1.37])
        returnKeyType = .continue
    }
}
