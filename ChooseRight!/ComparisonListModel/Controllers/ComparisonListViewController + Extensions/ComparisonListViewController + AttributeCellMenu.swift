//
//  ComparisonListViewController + AttributeCellMenu.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 05.06.2024.
//

import Foundation
import UIKit


extension ComparisonListViewController: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = interaction.view as? AttributesCollectionViewCell,
              let indexPath = self.attributesCollectionView.indexPath(for: cell) else { return nil }
        let identifier = indexPath.row
        
        attributesCollectionView.clipsToBounds = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.attributesCollectionView.clipsToBounds = true } //
        
        return UIContextMenuConfiguration(
            identifier: identifier as NSCopying) {
                return nil
                
            } actionProvider: { _ in
                
                
                self.attributesCollectionView.clipsToBounds = true

                let changingAttribute = self.comparisonAttributesFetchResultsController.fetchedObjects![indexPath.row]
                
                
                let menuTitle = changingAttribute.unwrappedName
                let changeNameAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [self] action in
                    
                    self.alertConfigurationForAttributeChangeName(attribute: changingAttribute)
                    
                    present(self.attributeChangeNameAlert ?? UIAlertController(), animated: true) { [weak self] in
                        guard let self = self else { return }
                        
                        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAttributeChangenameAlert))
                        
                        self.attributeChangeNameAlert?.view.window?.isUserInteractionEnabled = true
                        self.attributeChangeNameAlert?.view.superview?.subviews[0].addGestureRecognizer(dismissGesture)
                        
                    }
                    
                }
                
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, attributes: .destructive) { action in
                    
                    let delay = 0.4
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        self.sharedData.deleteComparisonAttribute(attribute: changingAttribute)
                    }
                    
                }
                
//                let deleteMenu = UIMenu(title: "", image: nil, identifier: nil, options: [.displayInline, .destructive], children: [deleteAction])
                
                return UIMenu(title: menuTitle,children: [
                    changeNameAction,
                    deleteAction
                ])
            }

    }
    
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configuration: UIContextMenuConfiguration, highlightPreviewForItemWithIdentifier identifier: any NSCopying) -> UITargetedPreview? {
//        guard let indexPath = configuration.identifier as? IndexPath,
//              let cell = attributesCollectionView.cellForItem(at: indexPath) as? AttributesCollectionViewCell else { return nil }
//        
//        let labelSnapshot = cell.attributeLabel.snapshotView(afterScreenUpdates: true)
//        labelSnapshot?.frame = cell.attributeLabel.frame
//        
//        
//                let parameters = UIPreviewParameters()
//                parameters.backgroundColor = .clear
//                parameters.visiblePath = UIBezierPath(roundedRect: cell.attributeLabel.frame, cornerRadius: 10)
//             
//        
//        
//                return UITargetedPreview(view: labelSnapshot!, parameters: parameters)
//    }
    
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        let attributeCellLocation = attributesCollectionView.convert(location, from: interaction.view)
//        
//        guard let indexPath = attributesCollectionView.indexPathForItem(at: attributeCellLocation) else { return nil }
//        
//        let identifier = indexPath.row //as NSString
//        
//        return UIContextMenuConfiguration(
//            identifier: identifier as NSCopying,
//            previewProvider: nil) { _ in
//                
//                let changingAttribute = self.comparisonAttributesFetchResultsController.fetchedObjects![indexPath.row]
//                
//                
//                let menuTitle = changingAttribute.unwrappedName
//                let changeNameAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { [self] action in
//                    
//                    self.alertConfigurationForAttributeChangeName(attribute: changingAttribute)
//                    
//                    present(self.attributeChangeNameAlert ?? UIAlertController(), animated: true) { [weak self] in
//                        guard let self = self else { return }
//                        
////                        self.dismissAttributeChangeNameAlertGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAttributeChangenameAlert))
//                        
//                        let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAttributeChangenameAlert))
//                        
//                        self.attributeChangeNameAlert?.view.window?.isUserInteractionEnabled = true
//                        self.attributeChangeNameAlert?.view.superview?.subviews[0].addGestureRecognizer(dismissGesture)
//                        
//                    }
//                    //                self.alertConfigurationForAttributeChangeName(attribute: changingAttribute)
//                    //
//                    //                present(self.attributeChangeNameAlert ?? UIAlertController(), animated: true) { [weak self] in
//                    //                    guard let self = self else { return }
//                    //
//                    //                    self.dismissAttributeChangeNameAlertGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAttributeChangenameAlert))
//                    
//                }
//                
//                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, attributes: .destructive) { action in
//                    
//                    self.sharedData.deleteComparisonAttribute(attribute: changingAttribute)
//                    
//                }
//                                
//                let deleteMenu = UIMenu(title: "", image: nil, identifier: nil, options: [.displayInline, .destructive], children: [deleteAction])
//                
//                
//                return UIMenu(title: menuTitle,children: [
//                    changeNameAction,
//                    deleteMenu
//                    
//                ])
//            }
//    }
    
    
    func alertConfigurationForAttributeChangeName(attribute: ComparisonAttributeEntity) {
        
        self.attributeChangeNameAlert = UIAlertController(title: "Edit attibute", message: "", preferredStyle: .alert)
        
        attributeChangeNameAlert?.addTextField { textfield in
            textfield.delegate = self
            textfield.autocapitalizationType = .sentences
            textfield.clearButtonMode = .always
            textfield.text = attribute.unwrappedName
            textfield.placeholder = "\(attribute.unwrappedName)"
            textfield.addTarget(self, action: #selector(self.textfieldChanged), for: .editingChanged)
        }
        
        let saveAttirbuteNameAction = UIAlertAction(title: "Save", style: .default) { [self, weak attributeChangeNameAlert] (_) in
            let textfieldText = attributeChangeNameAlert?.textFields?[0].text ?? "NoText"
            let savingResult = self.sharedData.updateComparisonAttributeName(for: attribute, newName: textfieldText)
            
            if savingResult == false {
            } else {
                self.attributesCollectionView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.attributeChangeNameAlert?.view.window?.removeGestureRecognizer(self.dismissAttributeChangeNameAlertGesture)
            self.attributeChangeNameAlert?.dismiss(animated: true) {
                self.attributeChangeNameAlert?.view.window?.removeGestureRecognizer(self.dismissAttributeChangeNameAlertGesture)
            }
            self.attributeChangeNameAlert = UIAlertController()
        }
        attributeChangeNameAlert?.addAction(saveAttirbuteNameAction)
        attributeChangeNameAlert?.addAction(cancelAction)
        saveAttributeButtonInAlertChanged = saveAttirbuteNameAction
        saveAttirbuteNameAction.isEnabled = false
        
    }
    
//    func setupAttributeCellMenu(indexPath: IndexPath) {
//        
//        let changeName = UIAction(
//            title: "Change name",
//            image: UIImage(systemName: "pencil")) { [self] _ in
//                let changingAttribute = self.comparisonAttributesFetchResultsController.fetchedObjects![indexPath.row]
//                self.alertConfigurationForAttributeChangeName(attribute: changingAttribute)
//                
//                present(self.attributeChangeNameAlert ?? UIAlertController(), animated: true) { [weak self] in
//                    guard let self = self else { return }
//                    
//                    self.dismissAttributeChangeNameAlertGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAttributeChangenameAlert))
//                }
//                
//                
//            }
//        
//    }
    
    @objc func dismissAttributeChangenameAlert() {
        self.attributeChangeNameAlert?.dismiss(animated: true)
        self.attributeChangeNameAlert?.view.window?.removeGestureRecognizer(self.dismissAttributeChangeNameAlertGesture)
    }
    
    
}















//extension ComparisonListViewController: UIGestureRecognizerDelegate {
//    
//    @objc func AttributeCellLongPress(gesture: UILongPressGestureRecognizer) {
//        
//        if gesture.state != .ended {
//            return
//        }
//        
//        let press = gesture.location(in: self.attributesCollectionView)
//        
//        if let indexPath = self.attributesCollectionView.indexPathForItem(at: press) {
//            let cell = self.attributesCollectionView.cellForItem(at: indexPath)
//        } else {
//        }
//    }
//    
//    func addLongPress() {
//        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(sender:)))
//        
//        attributesCollectionView.addGestureRecognizer(gesture)
//        gesture.delegate = self
//    }
//    
//    @objc func longPressAction(sender: UILongPressGestureRecognizer) {
//        
//        let generator = UIImpactFeedbackGenerator(style: .medium)
//        generator.impactOccurred()
//        
//        let location = sender.location(in: self.attributesCollectionView)
//        
//        
//        if self.tableCompressed {
//        
//        }
//        
//    }
//    
//}
