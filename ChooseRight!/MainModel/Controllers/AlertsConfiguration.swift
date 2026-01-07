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
    func alertConfigurationForCreate() {

        //New comparison configuration
        self.createNewComparisonListAlert? = UIAlertController(
            title: "Create new comparison",
            message: "",
            preferredStyle: .alert)
        
        createNewComparisonListAlert?.addTextField { alertTextfield in
            alertTextfield.autocapitalizationType = .sentences
            alertTextfield.clearButtonMode = .always
            alertTextfield.delegate = self
            alertTextfield.placeholder = "Name your comparison"
            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
        }
        
        let saveNewComparisonButton = UIAlertAction(title: "Start", style: .default) { [self, weak createNewComparisonListAlert] (_) in
                        
            var currentColor = specialColors[0]
            
            switch comparisonsArray.count {
                
            case 0: currentColor = specialColors[0]
                
            case 1...:
                
                let lastColor = comparisonsArray.first?.color ?? specialColors[0]
                let currentcolorindexis = specialColors.firstIndex(of: lastColor)
                currentColor = specialColors[(currentcolorindexis! + 1) % specialColors.count]
                
            default:
                currentColor = specialColors[0]
            }
            
            let textfieldText = createNewComparisonListAlert?.textFields?[0].text ?? "NoText"
                
                
                let savingResult = self.sharedDataBase.createComparison(name: textfieldText, color: currentColor)
                
                if savingResult == nil {
                    print("comparison doesn`t created")
                    
                    let emoji = warningMessageEmoji.randomElement() ?? ""
                    createNewComparisonListAlert?.message =
                    "\(emoji) \"\(textfieldText)\" already in use"
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)
                    
                    present(createNewComparisonListAlert ?? UIAlertController(), animated: true)
                } else {
                    
                    
                    let destination = ComparisonListViewController()
                    let comparison = sharedDataBase.fetchComparisonWithID(id: savingResult ?? "") ?? ComparisonEntity()
                    destination.setComparisonEntity(comparison: comparison)
                    notchView.alpha = 0
                    navigationController?.pushViewController(destination, animation: true) {
                        destination.notchView.alpha = 1
                        destination.openDetailsForNewComparison()
                    }
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
    func alertConfigurationForChangeName(comparison: ComparisonEntity) {
        
        //New comparison configuration
        self.createNameChangingAlert? = UIAlertController(
            title: "The old name is no good?",
            message: "",
            preferredStyle: .alert)
        
        createNameChangingAlert?.addTextField { alertTextfield in
            alertTextfield.delegate = self
            alertTextfield.autocapitalizationType = .sentences
            alertTextfield.clearButtonMode = .always
            alertTextfield.text = comparison.unwrappedName
            alertTextfield.placeholder = "Rename your comparison!"
            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
        }
        
        let saveNewComparisonButton = UIAlertAction(title: "Save", style: .default) { [self, weak createNameChangingAlert] (_) in
            
            let textfieldText = createNameChangingAlert?.textFields?[0].text ?? "NoText"
            let savingResult = self.sharedDataBase.updateComparisonName(for: comparison, newName: textfieldText)
            
            if savingResult == false {
                print("comparison doesn`t changed")
            } else {
                self.tableView.reloadData()
                print(textfieldText)
                print("savedComparisonID\(savingResult)")
            }
        }
        let cancelNewComparisonButton = UIAlertAction(title: "Cancel", style: .cancel)
        { _ in
            
            self.createNameChangingAlert?.view.window?.removeGestureRecognizer(self.dismissGesture)
            self.createNameChangingAlert?.dismiss(animated: true) {
                self.createNameChangingAlert?.view.window?.removeGestureRecognizer(self.dismissGesture)
            }
            self.createNameChangingAlert? = UIAlertController()
        }
        
        createNameChangingAlert?.addAction(saveNewComparisonButton)
        createNameChangingAlert?.addAction(cancelNewComparisonButton)
        saveButtonInAlertChanged = saveNewComparisonButton
        saveNewComparisonButton.isEnabled = false
    }
    
    func alertConfigurationForDeleteConfirmation(comparison: ComparisonEntity, index: Int ) {
        self.deleteComparisonConfirmationAlert? = UIAlertController(
            title: "Delete comparison?",
            message: "",
            preferredStyle: .actionSheet)
        
        let deleteButton = UIAlertAction(
            title: "Delete",
            style: .destructive) { [self] _ in
                self.deleteComparisonFromTable(comparison: comparison, index: index)
            }
        
        let cancelButton = UIAlertAction(
            title: "Cancel",
            style: .default)
        
        deleteComparisonConfirmationAlert?.addAction(deleteButton)
        deleteComparisonConfirmationAlert?.addAction(cancelButton)
    }
    
    
}

