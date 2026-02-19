//
//  ThemeManager.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 27.05.2024.
//

import Foundation
import UIKit

class ThemeManager {
    static func isLightTheme(for view: UIView) -> Bool  {
        if #available(iOS 12.0, *) {
            switch view.traitCollection.userInterfaceStyle {
            case .light:
                return true
            case .dark:
                return false
            case .unspecified:
                return false
            @unknown default:
                return true
            }
        } else {
            return true
        }
    }
    
    static func observeThemeChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTheme), name: .didChangeTheme, object: nil)
    }
    
    
    @objc func didChangeTheme() {
        // Note: This method signature is incorrect - isLightTheme requires a UIView parameter
        // This is a placeholder implementation
    }
    
    static func setTheme(isLight: Bool) {
        let style: UIUserInterfaceStyle = isLight ? .light : .dark
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.overrideUserInterfaceStyle = style
            }
        } else {
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = style
        }
    }
}

extension Notification.Name {
    static let didChangeTheme = Notification.Name("didChangeTheme")
}

