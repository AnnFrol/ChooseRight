//
//  MainViewControllerMenu.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 26.05.2024.
//

import Foundation
import UIKit
import MessageUI

extension MainViewController {
    
    func setupSettingsMenu() -> UIMenu {
        
        
        //1st menu element (version & share)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        let appInfoAction = UIAction(
            title: NSLocalizedString("Choose Right!", comment: ""),
            subtitle: String(format: NSLocalizedString("Version %@", comment: ""), version),
            image: UIImage(systemName: "square.and.arrow.up"),
            state: .off) { action in
                guard let url = URL(string: "https://apps.apple.com/app/id6759388003") else { return }
                let items = [url]
                let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                if let popover = ac.popoverPresentationController {
                    popover.sourceView = self.view
                    popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                self.present(ac, animated: true)
            }
        
        
        let appInfoMenu = UIMenu(
            title: "",
            options: .displayInline,
            children: [appInfoAction
                       /*shareAction*/])
        
        
        //2nd  menu element (theme switch)
        
        let isLightTheme = ThemeManager.isLightTheme(for: self.view)
        var themeActions = [UIAction]()
        
        if isLightTheme {
            let darkAction = UIAction(title: NSLocalizedString("Dark", comment: ""), image: UIImage(systemName: "moon.fill")) { action in
                    ThemeManager.setTheme(isLight: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateMenu()
                }
                }
            themeActions.append(darkAction)
        } else {
            let lightAction = UIAction(title: NSLocalizedString("Light", comment: ""), image: UIImage(systemName: "sun.max.fill")) { action in
                ThemeManager.setTheme(isLight: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateMenu()
                }
                        }
                        themeActions.append(lightAction)
        }
        
        let themeMenu = UIMenu(
            title: "",
            options: [.displayInline],
            children: themeActions)
                
        
        //3d menu element (contacts)
        
        
        let emailAction = UIAction(
            title: NSLocalizedString("Email", comment: ""),
            image: UIImage(named: "emailLogo"),
            identifier: nil,
            attributes: [],
            state: .off) { action in
                
                let email = "support@annfro.com"
                let subject = "ChooseRight! service request"
                let body = "Please describe your issue here"
                let coded = "mailto:\(email)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                if let url = URL(string: coded ?? "") {
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        
        let telegramAction = UIAction(
            title: NSLocalizedString("Telegram", comment: ""),
            image: UIImage(named: "telegramLogo")
        ) { action in
                if let url = URL(string: "https://t.me/AnnFroCom") {
                    UIApplication.shared.open(url)
                }
            }
        
        let instagramAction = UIAction(
            title: NSLocalizedString("Instagram", comment: ""),
            image: UIImage(named:"instagramLogo")
        ) { action in
                if let url = URL(string: "https://www.instagram.com/annfroltsova/") {
                    UIApplication.shared.open(url)
                }
            }
                
        let contactsMenu = UIMenu(
            title: NSLocalizedString("Contact us ", comment: ""),
            options: [.displayInline],
            children: [
                emailAction,
//                contactsAction,
                telegramAction,
                instagramAction
            ])
        
        // Purchase / premium status element
        let isPremiumUnlocked = SubscriptionManager.shared.hasActiveSubscription
        
        let purchaseMenu: UIMenu
        if isPremiumUnlocked {
            // Show non-tappable status when premium is already unlocked
            let unlockedAction = UIAction(
                title: NSLocalizedString("Premium unlocked", comment: ""),
                image: UIImage(systemName: "checkmark.seal.fill"),
                attributes: [.disabled]
            ) { _ in }
            
            purchaseMenu = UIMenu(
                title: "",
                options: .displayInline,
                children: [unlockedAction])
        } else {
            // Action to open purchase screen when premium is not unlocked yet
            let purchaseAction = UIAction(
                title: NSLocalizedString("Unlock Premium", comment: ""),
                image: UIImage(systemName: "star.fill")
            ) { _ in
                let subscriptionVC = SubscriptionViewController()
                subscriptionVC.modalPresentationStyle = .pageSheet
                if let sheet = subscriptionVC.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                }
                self.present(subscriptionVC, animated: true)
            }
            
            purchaseMenu = UIMenu(
                title: "",
                options: .displayInline,
                children: [purchaseAction])
        }
        
        let menuChildren: [UIMenuElement] = [
            purchaseMenu,
            appInfoMenu,
            themeMenu,
            contactsMenu
        ]
        
        let mainMenu = UIMenu(
            title: "",
            children: menuChildren)
        
        
        contactsMenu.preferredElementSize = .small
        
        return mainMenu
        
        }
    
    @objc func updateMenu() {
        let menu = self.setupSettingsMenu()
            self.settingsButton.menu = menu
            self.settingsButton.showsMenuAsPrimaryAction = true
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()

    }
    
    }
    
    
