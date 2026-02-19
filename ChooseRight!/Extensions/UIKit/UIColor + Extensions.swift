//
//  UIColor + Extensions.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 02.04.2023.
//

import UIKit

extension UIColor {
    
    struct specialColors {
        static let background = UIColor(named: "specialBackground")
        static let text = UIColor(named: "specialText")
        static let subviewBackground = UIColor(named: "specialSubviewBackground")
        
        static let oneBlueWinterWiazrd = UIColor(named: "specialOne")
        static let twoGreenMenthol = UIColor(named: "specialTwo")
        static let threeBlueLavender = UIColor(named: "specialThree")
        static let fourPinkBriliantLavender = UIColor(named: "specialFour")
        static let fiveYelowFlavescent = UIColor(named: "specialFive")
        static let sixGreenMagicMint = UIColor(named: "specialSix")
        static let sevenPinkMelon = UIColor(named: "specialSeven")
        static let eightYelowCalamansi = UIColor(named: "specialEight")
        static let ninePinkPaleMagenta = UIColor(named: "specialNine")
        
        static let detailsMainLabelText = UIColor(named: "specialDetailsMainLabelTextColor")
        static let detailsOptionTableText = UIColor(named: "specialDetailsOptionTableTextColor")
        static let detailsSecondaryLabelText = UIColor(named: "specialDetailsSecondaryLabelTextColor")
        static let plaseholder = UIColor(named: "specialPlaseholderColor")
        
        static let pdfAttributeTextColor = UIColor(named: "pdfAttributeTextColor")
    }
    
    func specialColorRandomise() -> UIColor {
        let colorsForCircleBG = [UIColor.specialColors.oneBlueWinterWiazrd,
                                 UIColor.specialColors.twoGreenMenthol,
                                 UIColor.specialColors.threeBlueLavender,
                                 UIColor.specialColors.fourPinkBriliantLavender,
                                 UIColor.specialColors.fiveYelowFlavescent,
                                 UIColor.specialColors.sixGreenMagicMint,
                                 UIColor.specialColors.sevenPinkMelon,
                                 UIColor.specialColors.eightYelowCalamansi,
                                 UIColor.specialColors.ninePinkPaleMagenta ]
        let colorIndex = Int.random(in: 0...8)
        return colorsForCircleBG[colorIndex] ?? .gray
    }
}
//case specialOneBlueWinterWiazrd
//case specialTwoGreenMenthol
//case specialThreeBlueLavender
//case specialFourPinkBriliantLavnder
//case specialFiveYelowFlavescent
//case specialSixGreenMagicMint
//case specialSevenPinkMelon
//case specialEightYelowCalamansi
//case specialNinePinkPaleMagenta
