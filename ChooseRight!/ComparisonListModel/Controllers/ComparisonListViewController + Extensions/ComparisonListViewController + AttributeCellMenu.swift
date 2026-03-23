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
        if let cell = interaction.view as? AttributesCollectionViewCell,
           let indexPath = self.attributesCollectionView.indexPath(for: cell) {
            let identifier = indexPath.row
            
            attributesCollectionView.clipsToBounds = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.attributesCollectionView.clipsToBounds = true }
            
            return UIContextMenuConfiguration(
                identifier: identifier as NSCopying) {
                    return nil
                    
                } actionProvider: { _ in
                    self.attributesCollectionView.clipsToBounds = true

                    let changingAttribute = self.comparisonAttributesFetchResultsController.fetchedObjects![indexPath.row]
                    let menuTitle = changingAttribute.unwrappedName
                    
                    let changeNameAction = UIAction(title: NSLocalizedString("Edit", comment: ""), image: UIImage(systemName: "pencil")) { [self] action in
                        self.alertConfigurationForAttributeChangeName(attribute: changingAttribute)
                        
                        present(self.attributeChangeNameAlert ?? UIAlertController(), animated: true) { [weak self] in
                            guard let self = self else { return }
                            
                            let dismissGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAttributeChangenameAlert))
                            
                            self.attributeChangeNameAlert?.view.window?.isUserInteractionEnabled = true
                            self.attributeChangeNameAlert?.view.superview?.subviews[0].addGestureRecognizer(dismissGesture)
                        }
                    }
                    
                    let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: ""), image: UIImage(systemName: "trash"), identifier: nil, attributes: .destructive) { action in
                        let delay = 0.4
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.sharedData.deleteComparisonAttribute(attribute: changingAttribute)
                        }
                    }
                    
                    return UIMenu(title: menuTitle,children: [
                        changeNameAction,
                        deleteAction
                    ])
                }
        }
        
        if let cell = interaction.view as? ValuesCollectionViewCell,
           let indexPath = self.valuesCollectionView.indexPath(for: cell) {
            let item = self.comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] ?? ComparisonItemEntity()
            let attribute = self.comparisonAttributesFetchResultsController.fetchedObjects?[indexPath.row] ?? ComparisonAttributeEntity()
            let value = self.sharedData.fetchValue(item: item, attribute: attribute)
            
            if !value.hasComment {
                DispatchQueue.main.async { [weak self] in
                    self?.showValueCommentAlert(for: value, at: indexPath)
                }
                return nil
            }
            
            return valueContextMenuConfiguration(for: indexPath)
        }
        
        return nil

    }
    
    private func valueContextMenuConfiguration(for indexPath: IndexPath) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: { [weak self] in
            guard let self = self else { return nil }
            
            let item = self.comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] ?? ComparisonItemEntity()
            let attribute = self.comparisonAttributesFetchResultsController.fetchedObjects?[indexPath.row] ?? ComparisonAttributeEntity()
            let value = self.sharedData.fetchValue(item: item, attribute: attribute)
            
            guard value.hasComment else { return nil }
            
            return self.makeValueCommentPreviewController(for: value)
        }) { [weak self] _ in
            guard let self = self else { return nil }
            
            let item = self.comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] ?? ComparisonItemEntity()
            let attribute = self.comparisonAttributesFetchResultsController.fetchedObjects?[indexPath.row] ?? ComparisonAttributeEntity()
            let value = self.sharedData.fetchValue(item: item, attribute: attribute)
            
            let editCommentTitle = value.hasComment
                ? NSLocalizedString("Edit comment", comment: "")
                : NSLocalizedString("Add comment", comment: "")
            
            let editCommentAction = UIAction(title: editCommentTitle, image: UIImage(systemName: "text.bubble")) { [weak self] _ in
                self?.showValueCommentAlert(for: value, at: indexPath)
            }
            
            var actions = [editCommentAction]
            
            if value.hasComment {
                let removeCommentAction = UIAction(
                    title: NSLocalizedString("Delete comment", comment: ""),
                    image: UIImage(systemName: "trash"),
                    attributes: .destructive
                ) { [weak self] _ in
                    self?.deleteValueComment(for: value, at: indexPath)
                }
                actions.append(removeCommentAction)
            }
            
            return UIMenu(title: "", children: actions)
        }
    }
    
    private func makeValueCommentPreviewController(for value: ComparisonValueEntity) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .specialColors.subviewBackground ?? UIColor.secondarySystemBackground
        
        let previewWidth: CGFloat = 280
        let previewInsets: CGFloat = 48
        let contentWidth = previewWidth - previewInsets
        let textFont = UIFont.systemFont(ofSize: 14)
        
        let textView = UITextView()
        textView.text = value.unwrappedComment
        textView.font = textFont
        textView.textColor = .specialColors.text ?? UIColor.label
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isSelectable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let textBounds = (value.unwrappedComment as NSString).boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: textFont],
            context: nil
        )
        let textHeight = ceil(textBounds.height)
        let minTextHeight: CGFloat = 44
        let maxTextHeight: CGFloat = 180
        let fittedTextHeight = min(max(textHeight, minTextHeight), maxTextHeight)
        textView.isScrollEnabled = textHeight > maxTextHeight
        
        controller.view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: controller.view.topAnchor, constant: 24),
            textView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor, constant: 24),
            textView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor, constant: -24),
            textView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor, constant: -24),
            textView.heightAnchor.constraint(equalToConstant: fittedTextHeight)
        ])
        
        controller.preferredContentSize = CGSize(width: previewWidth, height: fittedTextHeight + 48)
        return controller
    }
    
    private func showValueCommentAlert(for value: ComparisonValueEntity, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: NSLocalizedString("Comment", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = value.comment
            textField.placeholder = NSLocalizedString("Add comment", comment: "")
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .whileEditing
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { [weak self, weak alert] _ in
            guard let self = self else { return }
            let comment = alert?.textFields?.first?.text
            self.sharedData.updateComparisonComment(for: value, comment: comment)
            self.valuesCollectionView.reloadItems(at: [indexPath])
        })
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func deleteValueComment(for value: ComparisonValueEntity, at indexPath: IndexPath) {
        sharedData.updateComparisonComment(for: value, comment: nil)
        valuesCollectionView.reloadItems(at: [indexPath])
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
        
        self.attributeChangeNameAlert = UIAlertController(title: NSLocalizedString("Edit attribute", comment: ""), message: "", preferredStyle: .alert)
        
        attributeChangeNameAlert?.addTextField { textfield in
            textfield.delegate = self
            textfield.autocapitalizationType = .sentences
            textfield.clearButtonMode = .always
            textfield.text = attribute.unwrappedName
            textfield.placeholder = "\(attribute.unwrappedName)"
            textfield.addTarget(self, action: #selector(self.textfieldChanged), for: .editingChanged)
        }
        
        let saveAttirbuteNameAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { [self, weak attributeChangeNameAlert] (_) in
            let textfieldText = attributeChangeNameAlert?.textFields?[0].text ?? "NoText"
            let savingResult = self.sharedData.updateComparisonAttributeName(for: attribute, newName: textfieldText)
            
            if savingResult == false {
            } else {
                self.attributesCollectionView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
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
