//
//  SceneDelegateExtension.swift
//  ChooseRight!
//
//  Extension to easily switch between UIKit and SwiftUI versions
//

import UIKit

extension SceneDelegate {
    
    // Set this to true to use SwiftUI version, false for UIKit
    private static let useSwiftUI = true
    
    func setupRootViewController() {
        guard let windowScene = window?.windowScene else { return }
        
        if Self.useSwiftUI {
            // SwiftUI version
            let mainView = MainViewWrapper()
            let hostingController = MainViewHostingController(rootView: mainView)
            window?.rootViewController = UINavigationController(rootViewController: hostingController)
        } else {
            // UIKit version (original)
            window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        }
        
        window?.makeKeyAndVisible()
    }
}

