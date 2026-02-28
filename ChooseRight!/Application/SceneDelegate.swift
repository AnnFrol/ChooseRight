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
        
        // Handle URL if app was opened via URL or file
        if let urlContext = connectionOptions.urlContexts.first {
            // Delay handling to ensure window is fully set up
            DispatchQueue.main.async {
                self.handleURL(url: urlContext.url)
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        // Ensure window is ready before handling
        if window != nil {
            handleURL(url: url)
        } else {
            // If window not ready, delay handling
            DispatchQueue.main.async {
                self.handleURL(url: url)
            }
        }
    }
    
    private func handleURL(url: URL) {
        // Try to import - ComparisonSharingService will handle both URL schemes and file imports
        let result = ComparisonSharingService.importComparison(from: url)
        
        DispatchQueue.main.async {
            guard let navController = self.window?.rootViewController as? UINavigationController,
                  let topVC = navController.topViewController else {
                return
            }
            
            switch result {
            case .success:
                // Show success message and refresh main view
                if let mainVC = navController.viewControllers.first as? MainViewController {
                    mainVC.viewWillAppear(false)
                    
                    // Show success alert with checkmark
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        mainVC.showImportSuccessAlert()
                    }
                } else {
                    // If onboarding is showing, just show alert on top view controller
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        topVC.showImportSuccessAlert()
                    }
                }
                
            case .failed(let error):
                var alertTitle = "Import Failed"
                var alertMessage = "Could not import the comparison file."
                var showSubscription = false
                
                switch error {
                case .limitExceeded:
                    alertTitle = "Limit Exceeded"
                    alertMessage = "You have reached the free limit of 1 comparison. Please upgrade to Premium to import more comparisons."
                    showSubscription = true
                case .invalidFile:
                    alertMessage = "Could not import the comparison file. Please make sure the file is valid."
                case .saveError:
                    alertMessage = "Could not save the comparison. Please try again."
                }
                
                let alert = UIAlertController(
                    title: alertTitle,
                    message: alertMessage,
                    preferredStyle: .alert
                )
                
                if showSubscription {
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Upgrade", comment: ""), style: .default) { _ in
                        let subscriptionVC = SubscriptionViewController()
                        subscriptionVC.modalPresentationStyle = .pageSheet
                        if let sheet = subscriptionVC.sheetPresentationController {
                            sheet.detents = [.large()]
                            sheet.prefersGrabberVisible = true
                        }
                        topVC.present(subscriptionVC, animated: true)
                    })
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
                } else {
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
                }
                
                topVC.present(alert, animated: true)
            }
        }
    }
}

