//
//  ComparisonListViewController + ObjectCellMenu.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 29.06.2024.
//

import Foundation
import UIKit

extension ComparisonListViewController {
    
    func setupObjectCellMenu(indexPath: IndexPath) {
        
        guard let changingComparisonItem = self.comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] else { return }
        let menuTitle = changingComparisonItem.unwrappedName
        
        let renameItem = UIAction(title: NSLocalizedString("Change name", comment: ""), image: UIImage(systemName: "pencil")) { [weak self] _ in
            guard let self = self else { return }
            self.showRenameItemAlert(for: changingComparisonItem)
        }
        
        let changeColor = UIAction(title: NSLocalizedString("Change color", comment: ""), image: UIImage(systemName: "paintpalette")) { [weak self] _ in
            guard let self = self else { return }
            self.showColorPicker(for: changingComparisonItem, at: indexPath)
        }
        
        let deleteItem = UIAction(title: NSLocalizedString("Delete", comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { [self] _ in
            guard let deleteItem = self.comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] else { return }
            
            self.alertConfigurationForDeleteItemConfirmation(comparisonItem: deleteItem)
            present(deleteItemAlert ?? UIAlertController(), animated: true) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.deleteItemAlertDismiss))
                self.deleteItemAlert?.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
        }
        
        objectCellMenu = UIMenu(
            title: menuTitle,
            image: UIImage(systemName: "peacesign"),
            children: [renameItem, changeColor, deleteItem]
        )
        
        
    }
    
    @objc func deleteItemAlertDismiss() {
        self.dismiss(animated: true)
    }
    
    
    func alertConfigurationForDeleteItemConfirmation(comparisonItem: ComparisonItemEntity) {
        
        let itemToDelete = comparisonItem
        let itemName = itemToDelete.unwrappedName
        
        self.deleteItemAlert = UIAlertController(
            title: String(format: NSLocalizedString("Delete %@?", comment: ""), itemName),
            message: "",
            preferredStyle: .actionSheet)
        
        let deleteButton = UIAlertAction(
            title: NSLocalizedString("Delete", comment: ""),
            style: .destructive) { [self] _ in
                self.sharedData.deleteComparisonItem(item: itemToDelete)
            }
        
        let cancelButton = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: ""),
            style: .default)
        
        deleteItemAlert?.addAction(deleteButton)
        deleteItemAlert?.addAction(cancelButton)
        
        // Configure popover for iPad
        if let popover = deleteItemAlert?.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
    }
    
    func makeCellPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        
        guard let cell = objectTableView.cellForRow(at: indexPath) as? ObjectTableViewCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(
            roundedRect: cell.backgroundCell.bounds,
            cornerRadius: cell.backgroundCell.layer.cornerRadius
        )
        
        return UITargetedPreview(view: cell.backgroundCell, parameters: parameters)
        
    }
    
    func showRenameItemAlert(for item: ComparisonItemEntity) {
        let alert = UIAlertController(
            title: NSLocalizedString("Change name", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.text = item.unwrappedName
            textField.placeholder = NSLocalizedString("New name", comment: "")
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default) { [weak self] _ in
            guard let self = self,
                  let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty else { return }
            if self.sharedData.updateComparisonItemName(for: item, newName: newName) {
                self.objectTableView.reloadData()
                self.valuesCollectionView.reloadData()
            }
        })
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
    
    func showColorPicker(for item: ComparisonItemEntity, at indexPath: IndexPath) {
        let colorPicker = ColorPickerViewController(
            selectedColor: item.color,
            onColorSelected: { [weak self] colorName in
                guard let self = self else { return }
                self.sharedData.updateComparisonItemColor(for: item, newColor: colorName)
            }
        )
        
        if let sheet = colorPicker.sheetPresentationController {
            sheet.detents = [.custom { _ in
                return UIScreen.main.bounds.height / 3
            }]
            sheet.prefersGrabberVisible = true
        }
        
        colorPicker.modalPresentationStyle = .pageSheet
        present(colorPicker, animated: true)
    }
    
}
