//
//  UILabel + Extensions.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 01.04.2023.
//

import UIKit

extension UILabel {
    
// MARK: Labels for MainView
    
    convenience init(comparisonNameLabelText: String = "") {
        self.init()
        self.text = comparisonNameLabelText
        self.textColor = .specialColors.text
        self.font = .sfProTextMedium24()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
// MARK: Labels for CompairsonListView
    
    convenience init(mainLabelText: String = "") {
        self.init()
        self.text = mainLabelText
        self.textColor = .specialColors.text
        self.font = .sfProTextBold33()
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.5
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(containerLabelText: String = "") {
        self.init()
        self.text = containerLabelText
        self.textColor = .specialColors.text
        self.font = .sfProTextMedium16()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(percentContainerLabelText: String = "") {
        self.init()
        self.text = percentContainerLabelText
        self.textColor = .specialColors.text
        self.font = .sfProTextMedium12()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(attributeLabelText: String = "") {
        self.init()
        self.textAlignment = .center
        self.text = attributeLabelText
        self.textColor = .specialColors.detailsOptionTableText
        self.font = .sfProTextRegular14()
        self.alpha = 0.6
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(insideTableText: String = "") {
        self.init()
        self.text = insideTableText
        self.textColor = .black
        self.font = .sfProTextRegular20()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
// MARK: Labels for ObjectDdetailsView
    
    convenience init(detailsSecondaryLabelText: String = "") {
        self.init()
        self.text = detailsSecondaryLabelText
        self.textColor = .specialColors.detailsSecondaryLabelText
        self.font = .sfProDisplayRegular15()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(detailsRelevanseValueLabelText: String = "") {
        self.init()
//        self.text = detailsRelevanseValueLabelText
        self.attributedText = NSMutableAttributedString(string: "\(detailsRelevanseValueLabelText)%", attributes: [NSAttributedString.Key.kern: -4])
        self.textColor = .specialColors.detailsMainLabelText
        self.font = .sfProTextSemibold80()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(detailsScoreValueLabelText: String = "") {
        self.init()
        self.text = detailsScoreValueLabelText
        self.textColor = .specialColors.detailsMainLabelText
        self.font = .sfProTextSemibold33()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(detailsTableValueLabel: String = "") {
        self.init()
        self.text = detailsTableValueLabel
        self.textColor = .black
        self.font = .sfProTextRegular23()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(popOverMenuLabelText: String = "") {
        self.init()
        self.text = popOverMenuLabelText
        self.textColor = .specialColors.text
        self.font = .sfProTextRegular16()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
