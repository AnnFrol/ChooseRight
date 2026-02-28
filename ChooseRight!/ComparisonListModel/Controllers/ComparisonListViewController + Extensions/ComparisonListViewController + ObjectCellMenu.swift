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
            children: [changeColor, deleteItem]
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
        
        let cellFrame = cell.backgroundCell.frame
        
//        guard let item = comparisonItemsFetchResultsController.fetchedObjects?[indexPath.section] as? ComparisonItemEntity else { return nil }
        
//        let previewFrame = CGRect(
//            x: cellFrame.minX,
//            y: cellFrame.minY,
//            width: 250,
//            height: cellFrame.height
//        )
        
//        let previewView = ObjectTableViewCellPreview(frame: previewFrame)
//        previewView.configureCell(comparisonItemEntity: item)
//        previewView.translatesAutoresizingMaskIntoConstraints = true
//        previewView.frame = previewFrame
//        view.addSubview(previewView)
//        
//        let snapshot = previewView.snapshotView(afterScreenUpdates: true)
//        previewView.removeFromSuperview()
//        
//        guard let snapshotView = snapshot else { return nil }
//        
//        snapshotView.layer.cornerRadius = cell.backgroundCell.layer.cornerRadius
//        snapshotView.layer.masksToBounds = true
//        
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(roundedRect: cellFrame, cornerRadius: cell.backgroundCell.layer.cornerRadius)
        
        return UITargetedPreview(view: cell, parameters: parameters)
        
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
