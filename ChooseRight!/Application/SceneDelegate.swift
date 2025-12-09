//
//  SceneDelegate.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 01.04.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Проверяем, был ли уже показан onboarding
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding {
            window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        } else {
            window?.rootViewController = OnboardingViewController()
        }
        
        window?.makeKeyAndVisible()
        
    }
}

