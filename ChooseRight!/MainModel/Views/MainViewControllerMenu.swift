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
                    
                    guard let url = URL(string: "https://annfrol.github.io/") else { return }
                    
                    let items = [url]
                    
                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    
                    self.present(ac, animated: true)
                    print(version)
                }
        } else {
             appInfoAction = UIAction(title: "Choose Right!\nVersion: \(version)", image: logo, identifier: nil, discoverabilityTitle: "discTitle", attributes: [], state: .off) { action in
                print(version)
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
                print("1.\(ThemeManager.isLightTheme(for: self.view))")

                    ThemeManager.setTheme(isLight: false)
//                    self.settingsButton.menu = self.setupSettingsMenu()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateMenu()
                    print("2.\(ThemeManager.isLightTheme(for: self.view))")

                }
                
                }
            themeActions.append(darkAction)
        } else {
            let lightAction = UIAction(title: "Light", image: UIImage(systemName: "sun.max.fill")) { action in
                
                print("1.\(ThemeManager.isLightTheme(for: self.view))")

                    ThemeManager.setTheme(isLight: true)
//                    self.settingsButton.menu = self.setupSettingsMenu()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateMenu()
                    print("2.\(ThemeManager.isLightTheme(for: self.view))")

                }
                print("2.\(ThemeManager.isLightTheme(for: self.view))")

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
                
                let email = "alexfro74@gmail.com"
                let subject = "ChooseRight! service request"
                let body = "Please describe your issue here"
                let coded = "mailto:\(email)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                if let url = URL(string: coded ?? "") {
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        print("Cant`t open eMail")
                    }
                }
            }
        
        let telegramAction = UIAction(
            title: "Telegram",
            image: UIImage(named: "telegramLogo")
        ) { action in
                if let url = URL(string: "https://t.me/AlexanderFro") {
                    UIApplication.shared.open(url)
                }
            }
        
        let instagramAction = UIAction(
            title: "Instagram",
            image: UIImage(named:"instagramLogo")
        ) { action in
                if let url = URL(string: "https://www.instagram.com/alexfroool/") {
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
        
        // Test file import (DEBUG only)
        #if DEBUG
        let testFileImportAction = UIAction(
            title: "Test File Import",
            image: UIImage(systemName: "doc.badge.plus")
        ) { action in
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            self.present(documentPicker, animated: true)
        }
        
        let testMenu = UIMenu(
            title: "",
            options: .displayInline,
            children: [testFileImportAction])
        #endif
        
        var menuChildren: [UIMenuElement] = [
            appInfoMenu,
            themeMenu,
            contactsMenu
        ]
        
        #if DEBUG
        menuChildren.append(testMenu)
        #endif
        
        let mainMenu = UIMenu(
            title: "",
            children: menuChildren)
        
        
        if #available(iOS 16.0, *) {
            contactsMenu.preferredElementSize = .small
        } else {
            // Fallback on earlier versions
            print("preferredElementSize not avalible")
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
    
    
