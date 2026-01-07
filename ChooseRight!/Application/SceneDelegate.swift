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
        
        // Handle URL if app was opened via URL
        if let urlContext = connectionOptions.urlContexts.first {
            handleURL(url: urlContext.url)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleURL(url: url)
    }
    
    private func handleURL(url: URL) {
        var success = false
        
        // Try URL scheme first
        if url.scheme == ComparisonSharingService.urlScheme {
            success = ComparisonSharingService.importComparison(from: url)
        } else if url.pathExtension == "chooseright" {
            // Handle file import
            success = ComparisonSharingService.importComparison(from: url)
        }
        
        guard success else {
            return
        }
        
        // Show success message and refresh main view
        if let navController = window?.rootViewController as? UINavigationController,
           let mainVC = navController.viewControllers.first as? MainViewController {
            mainVC.viewWillAppear(false)
            
            // Show success alert
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alert = UIAlertController(
                    title: "Comparison imported",
                    message: "The comparison has been successfully added to your list.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                mainVC.present(alert, animated: true)
            }
        }
    }
}

