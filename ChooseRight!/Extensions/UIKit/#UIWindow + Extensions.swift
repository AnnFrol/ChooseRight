//
//  UIWindow + Extensions.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 14.03.2024.
//

import Foundation
import UIKit

final class AttributesContextMenuWindow: UIWindow {
        
    override var windowLevel: UIWindow.Level {
        get {
            return UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude - 1)
        }
        set {}
    }
}
