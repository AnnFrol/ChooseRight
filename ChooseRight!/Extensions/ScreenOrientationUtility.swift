//
//  ScreenOrientationUtility.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 26.06.2024.
//

import Foundation
import UIKit

struct ScreenOrientationUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return }
        rootViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
        windowScene.requestGeometryUpdate(.iOS(
            interfaceOrientations: windowScene.interfaceOrientation.isLandscape
                ? .portrait
                : .landscapeRight
        ))
    }
    
}
