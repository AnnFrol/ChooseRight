//
//  AlertsConfiguration.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 22.07.2023.
//

import Foundation
import UIKit
import CoreData
//MARK: - Alerts configuration

extension MainViewController: UITextFieldDelegate {
    
    @objc private func textFieldChanged(_ sender: Any) {
        let textfield = sender as! UITextField
        guard let textfieldText = textfield.text else { return }
        print(textfieldText)
        let comparisonsNames: [String] = comparisonsArray.map { $0.unwrappedName }
        self.saveButtonInAlertChanged?.isEnabled = !textfieldText.trimmingCharacters(in: .whitespaces).isEmpty && !comparisonsNames.contains(textfieldText)
    }
    
//MARK: alertsConfigurationForCreate
    func alertsConfigurationForCreate() {

        //New comparison configuration
        self.createNewComparisonListAlert? = UIAlertController(
            title: "Create new comparison",
            message: "",
            preferredStyle: .alert)
        
        createNewComparisonListAlert?.addTextField { alertTextfield in
            alertTextfield.delegate = self
            alertTextfield.placeholder = "Name your comparison"
            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
        }
        
        let saveNewComparisonButton = UIAlertAction(title: "Start", style: .default) { [self, weak createNewComparisonListAlert] (_) in
            
            let textfieldText = createNewComparisonListAlert?.textFields?[0].text ?? "NoText"
            let savingResult = self.sharedDataBase.createComparison(name: textfieldText)
            
            if savingResult == nil {
                print("comparison doesn`t created")
                
                let emoji = warningMessageEmoji.randomElement() ?? ""
                createNewComparisonListAlert?.message =
                "\(emoji) \"\(textfieldText)\" already in use"
                
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                
                present(createNewComparisonListAlert ?? UIAlertController(), animated: true)
            } else {
                self.objectDetailsViewController.transitioningDelegate = self
                self.objectDetailsViewController.modalPresentationStyle = .fullScreen
                self.objectDetailsViewController.setForNewItem(comparisonID: savingResult ?? "", needUpdateViewController:  false)
                self.objectDetailsViewController.endCreatingDelegate = self
                present(self.objectDetailsViewController, animated: true)
                print(textfieldText)
                print("savedComparisonID: \(savingResult ?? "NOT SAVED")" )
            }
        }
        let cancelNewComparisonButton = UIAlertAction(title: "Cancel", style: .cancel)
        { _ in
            self.createNewComparisonListAlert?.dismiss(animated: true)
            self.createNewComparisonListAlert? = UIAlertController()
        }
        
        createNewComparisonListAlert?.addAction(saveNewComparisonButton)
        createNewComparisonListAlert?.addAction(cancelNewComparisonButton)
        saveButtonInAlertChanged = saveNewComparisonButton
        saveNewComparisonButton.isEnabled = false
    }
    
//MARK: alertsConfigurationForChangeName
    func alertsConfigurationForChangeName(comparison: ComparisonEntity) {
        
        //New comparison configuration
        self.createNameChangingAlert? = UIAlertController(
            title: "The old name is no good?",
            message: "",
            preferredStyle: .alert)
        
        createNameChangingAlert?.addTextField { alertTextfield in
            alertTextfield.delegate = self
            alertTextfield.placeholder = "Rename your comparison!"
            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
        }
        
        let saveNewComparisonButton = UIAlertAction(title: "Start", style: .default) { [self, weak createNameChangingAlert] (_) in
            
            let textfieldText = createNameChangingAlert?.textFields?[0].text ?? "NoText"
            let savingResult = self.sharedDataBase.updateComparisonName(for: comparison, newName: textfieldText)
            
            if savingResult == false {
                print("comparison doesn`t changed")
                
//                let emoji = warningMessageEmoji.randomElement() ?? ""
//                createNameChangingAlert?.message =
//                "\(emoji) \"\(textfieldText)\" already in use"
//
//                let generator = UINotificationFeedbackGenerator()
//                generator.notificationOccurred(.error)
//
//                present(createNameChangingAlert ?? UIAlertController(), animated: true)
            } else {
                self.objectDetailsViewController.transitioningDelegate = self
                self.objectDetailsViewController.modalPresentationStyle = .fullScreen
//                self.objectDetailsViewController.setComparisonEntity(comparisonID: savingResult ?? "")
                presentingViewController?.present(self.objectDetailsViewController, animated: true)
                print(textfieldText)
                print("savedComparisonID\(savingResult)" )
            }
        }
        let cancelNewComparisonButton = UIAlertAction(title: "Cancel", style: .cancel)
        { _ in
            self.createNameChangingAlert?.dismiss(animated: true)
            self.createNameChangingAlert? = UIAlertController()
        }
        
        createNameChangingAlert?.addAction(saveNewComparisonButton)
        createNameChangingAlert?.addAction(cancelNewComparisonButton)
        saveButtonInAlertChanged = saveNewComparisonButton
        saveNewComparisonButton.isEnabled = false
    }
}

