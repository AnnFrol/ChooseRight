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
        let logo = UIImage(named: "AppstoreLogo")
//        let logo = UIImage(named: "AppleLogo")
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        var appInfoAction = UIAction { action in
        }
        
        if #available(iOS 17.0, *) {
             appInfoAction = UIAction(
                title: "Choose Right!",
                subtitle: "Version \(version)",
                image: UIImage(systemName: "square.and.arrow.up"),
                state: .off) { action in
                    
                    guard let url = URL(string: "https://apps.apple.com/app/id6759388003") else { return }
                    
                    let items = [url]
                    
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    
                    // Configure popover for iPad
                    if let popover = ac.popoverPresentationController {
                        popover.sourceView = self.view
                        popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    self.present(ac, animated: true)
                }
        } else {
             appInfoAction = UIAction(title: "Choose Right!\nVersion: \(version)", image: logo, identifier: nil, discoverabilityTitle: "discTitle", attributes: [], state: .off) { action in
            }        }
        
        
        let appInfoMenu = UIMenu(
            title: "",
            options: .displayInline,
            children: [appInfoAction
                       /*shareAction*/])
        
        
        //2nd  menu element (theme switch)
        
        let isLightTheme = ThemeManager.isLightTheme(for: self.view)
        var themeActions = [UIAction]()
        
        if isLightTheme {
            let darkAction = UIAction(title: "Dark", image: UIImage(systemName: "moon.fill")) { action in
                    ThemeManager.setTheme(isLight: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateMenu()
                }
                }
            themeActions.append(darkAction)
        } else {
            let lightAction = UIAction(title: "Light", image: UIImage(systemName: "sun.max.fill")) { action in
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
            title: "Email",
            image: UIImage(named: "emailLogo"),
            identifier: nil,
            attributes: [],
            state: .off) { action in
                
                let email = "ann.desi.d@gmail.com"
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
            title: "Telegram",
            image: UIImage(named: "telegramLogo")
        ) { action in
                if let url = URL(string: "https://t.me/AnnKolnobro") {
                    UIApplication.shared.open(url)
                }
            }
        
        let instagramAction = UIAction(
            title: "Instagram",
            image: UIImage(named:"instagramLogo")
        ) { action in
                if let url = URL(string: "https://www.instagram.com/ann_kolnobr/") {
                    UIApplication.shared.open(url)
                }
            }
                
        let contactsMenu = UIMenu(
            title: "Contact us ",
            options: [.displayInline],
            children: [
                emailAction,
//                contactsAction,
                telegramAction,
                instagramAction
            ])
        
        // Purchase menu element (first)
        let purchaseAction = UIAction(
            title: "Unlock Premium",
            image: UIImage(systemName: "star.fill")
        ) { action in
            let subscriptionVC = SubscriptionViewController()
            subscriptionVC.modalPresentationStyle = .pageSheet
            if #available(iOS 15.0, *) {
                if let sheet = subscriptionVC.sheetPresentationController {
                    sheet.detents = [.large()]
                    sheet.prefersGrabberVisible = true
                }
            }
            self.present(subscriptionVC, animated: true)
        }
        
        let purchaseMenu = UIMenu(
            title: "",
            options: .displayInline,
            children: [purchaseAction])
        
        let menuChildren: [UIMenuElement] = [
            purchaseMenu,
            appInfoMenu,
            themeMenu,
            contactsMenu
        ]
        
        let mainMenu = UIMenu(
            title: "",
            children: menuChildren)
        
        
        if #available(iOS 16.0, *) {
            contactsMenu.preferredElementSize = .small
        }
        
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
    
    
