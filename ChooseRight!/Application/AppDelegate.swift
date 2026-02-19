//
//  AppDelegate.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 01.04.2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    // MARK: - Handle file opening
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle URL scheme
        if url.scheme == ComparisonSharingService.urlScheme {
            let result = ComparisonSharingService.importComparison(from: url)
            return result == .success
        }
        
        // Handle file import
        if url.pathExtension == "chooseright" {
            let result = ComparisonSharingService.importComparison(from: url)
            return result == .success
        }
        
        return false
    }
    
    
//MARK: - Core Data -
    
    //MARK: - PersistentContainer
    lazy var persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "ComparisonsBase")
        container.loadPersistentStores { description, error in
            if let error {
                // Error loading persistent store
            } else {
                guard let path = description.url?.absoluteString else { return }
            }
        }
        return container
    }()
    
    
    //MARK: - Context
    
    class var viewContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    class var backgroundContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
        
    }
    
    
    //MARK: - Save context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Log error instead of crashing in production
                #if DEBUG
                fatalError(error.localizedDescription)
                #endif
            }
        }
    }
    
    //MARK: - Screen orientation
    
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
}

