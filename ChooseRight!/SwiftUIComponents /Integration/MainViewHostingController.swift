//
//  MainViewHostingController.swift
//  ChooseRight!
//
//  UIViewController wrapper for SwiftUI MainView
//  Use this to integrate SwiftUI MainView into existing UIKit navigation
//

import UIKit
import SwiftUI

class MainViewHostingController: UIHostingController<MainViewWrapper> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupNavigation() {
        // Hide navigation bar to match original design
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNavigateToComparison(_:)),
            name: NSNotification.Name("NavigateToComparison"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNavigateToNewComparison(_:)),
            name: NSNotification.Name("NavigateToNewComparison"),
            object: nil
        )
    }
    
    @objc private func handleNavigateToComparison(_ notification: Notification) {
        guard let comparison = notification.userInfo?["comparison"] as? ComparisonEntity else { return }
        
        let destination = ComparisonListViewController()
        destination.setComparisonEntity(comparison: comparison)
        navigationController?.pushViewController(destination, animated: true)
    }
    
    @objc private func handleNavigateToNewComparison(_ notification: Notification) {
        guard let comparison = notification.userInfo?["comparison"] as? ComparisonEntity else { return }
        
        let destination = ComparisonListViewController()
        destination.setComparisonEntity(comparison: comparison)
        navigationController?.pushViewController(destination, animation: true) {
            destination.openDetailsForNewComparison()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - SwiftUI View with Navigation Support
struct MainViewWrapper: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showCreateAlert = false
    @State private var showDeleteAlert = false
    @State private var showRenameAlert = false
    @State private var selectedComparison: ComparisonEntity?
    @State private var newComparisonName = ""
    @State private var renameText = ""
    
    var body: some View {
        MainView(
            onComparisonSelected: { comparison in
                navigateToComparison(comparison)
            },
            onNewComparisonCreated: { comparison in
                navigateToNewComparison(comparison)
            }
        )
    }
    
    
    private func navigateToComparison(_ comparison: ComparisonEntity) {
        // Use NotificationCenter to communicate with the hosting controller
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToComparison"),
            object: nil,
            userInfo: ["comparison": comparison]
        )
    }
    
    private func navigateToNewComparison(_ comparison: ComparisonEntity) {
        // Use NotificationCenter to communicate with the hosting controller
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToNewComparison"),
            object: nil,
            userInfo: ["comparison": comparison]
        )
    }
}

