////
////  AlertsConfigurationForAttributesCollection.swift
////  ChooseRight!
////
////  Created by Александр Фрольцов on 14.03.2024.
////
//
//import Foundation
//import UIKit
//
//extension ComparisonListViewController: UITextFieldDelegate {
//    
//    @objc private func textFieldChanged(_ sender: Any) {
//        let textfield = sender as! UITextField
//        guard let textfieldText = textfield.text else { return }
//        print(textfieldText)
//        let attributesNames: [String] = comparisonAttributesFetchResultsController.fetchedObjects?.map { $0.unwrappedName } ?? ["NoNamesFetched"]
////        self.
//    }
//    
//    //MARK: alertsConfigurationForChangeName
//    func alertsConfigurationForChangeAttributeName(attribute: ComparisonAttributeEntity) {
//        
//        self.createAttributeNameChangingAllert = UIAlertController(title: "Edit attribute", message: "", preferredStyle: .alert)
//        
//        self.createAttributeNameChangingAllert?.addTextField { alertTextfield in
//            alertTextfield.delegate = self
//            alertTextfield.placeholder = "\(attribute.unwrappedName)"
//            alertTextfield.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
//        }
//    }
//    let saveButton = UIAlertAction(title: "Save", style: .default) { [self, weak createAttributeNameChangingAllert] (_) in
//        
//        let textfield
//    }
//    
//}
