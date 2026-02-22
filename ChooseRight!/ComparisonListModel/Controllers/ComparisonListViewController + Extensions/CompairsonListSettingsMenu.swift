import UIKit
import Foundation

struct itemSortKeys {
    let name = "name"
    let date = "date"
    let value = "trueValuesCount"
}

extension ComparisonListViewController {
    
    func sharePdf(pdfURL: URL) {
        guard FileManager.default.fileExists(atPath: pdfURL.path) else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        
        // Для iPad нужно указать sourceView
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true)
    }

    

    
    func  setupSettingsMenu() -> UIMenu {
        var menu = UIMenu()
        
        let sharePDFAction = UIAction(title: "Download PDF", image: UIImage(systemName: "square.and.arrow.down"), handler: { _ in
            guard let pdfFile = PDFService.getPdfDocument(fetchedItems: self.comparisonItemsFetchResultsController) else { return }
            
            self.sharePdf(pdfURL: pdfFile)
        })
        
        
        let shareLinkAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up"), handler: { _ in
            // Always use file for sharing
            guard let shareFile = ComparisonSharingService.createShareFile(from: self.comparisonEntity) else {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Failed to create share file",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            
            let shareText = "Check out this comparison from ChooseRight! https://apps.apple.com/app/id6759388003"
            let activityViewController = UIActivityViewController(activityItems: [shareText, shareFile], applicationActivities: nil)
            
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            self.present(activityViewController, animated: true)
        })
        
        let deleteListAction = UIAction(title: "Delete list", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.showDeleteComparisonAlert()
        })
        
        let generateValuesAction = UIAction(title: "Generate values", image: UIImage(systemName: "sparkles"), handler: { [weak self] _ in
            guard let self = self else { return }
            self.showGenerateValuesInTableAlert()
        })
        
        
//        let verticalOrientationAction = UIAction(title: "Vertical", image: UIImage(named: "arrowDown"), state: .on, handler: { _ in
//            print("Vertical")})
//        
//        let horizontalOrientationAction = UIAction(title: "Horizontal", image: UIImage(named: "arrowRight"), identifier: .none, discoverabilityTitle: nil, state: .off, handler: { _ in
//            print("Horizontal")})
        
//        let orientationSubMenu = UIMenu(options: .displayInline, children: [
//            verticalOrientationAction,
//            horizontalOrientationAction
//        ])
        
        let percentSortingAction = UIAction(title: "Percent", image: currentSortKey == itemSortKeys().value ? UIImage(named: "shakeMotion") : nil, state: currentSortKey == itemSortKeys().value ? .on : .off, handler: { _ in
                        
            
            
            self.updateSortKey("trueValuesCount")
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showToast(message: "Shake to reorder", icon: UIImage(named:"shakeMotion"), duration: 1.5)
                }
        })
        
        let dateSortingAction = UIAction(title: "Created", state: currentSortKey == itemSortKeys().date ? .on : .off, handler: { _ in
            self.updateSortKey(itemSortKeys().date)
        })
        
        let nameSortingAction = UIAction(title: "Name", state: currentSortKey == itemSortKeys().name ? .on : .off, handler: { _ in
            self.updateSortKey("name")
        })
        
        let sortingSubMenu = UIMenu(title: "Sort", options: .displayInline, children: [
            percentSortingAction,
            dateSortingAction,
            nameSortingAction
        ])
                
        menu = UIMenu(title: "", image: nil,children: [
            sortingSubMenu,
            generateValuesAction,
            shareLinkAction,
            sharePDFAction,
            deleteListAction,
        ])
        
        return menu
    }
    
    //MARK setupAttributesCellMenu
    func setupAttributesCellMenu(attribute: ComparisonAttributeEntity) {
        let changeAttributesNameAction = UIAction(title: "Edit attribute", handler: { _ in
        })
        
        let deleteAttributeAction = UIAction(title: "Delete attribute", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
        }
        
        attributeCellMenu = UIMenu(title: "attribute name", image: nil,
                                   children: [changeAttributesNameAction, deleteAttributeAction])
        
        
    }
    
    //MARK: - Delete Comparison
    func showDeleteComparisonAlert() {
        let alert = UIAlertController(
            title: "Delete comparison?",
            message: "This action cannot be undone.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteComparison()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Configure popover for iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    private func deleteComparison() {
        // Удаляем сравнение из базы данных
        sharedData.deleteComparison(comparison: comparisonEntity)
        
        // Возвращаемся на главный экран
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Generate values in table (AI)
    func showGenerateValuesInTableAlert() {
        let items = comparisonEntity.itemsArray
        let attributes = comparisonEntity.attributesArray
        guard items.count >= 2, attributes.count >= 1 else {
            let alert = UIAlertController(
                title: "Cannot generate values",
                message: "You need at least 2 items and 1 attribute to generate values.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if let popover = alert.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(
            title: "Generate values",
            message: "AI will fill the table with +/‑ for each item and criterion. Existing values will be overwritten.\n\nAI can make mistakes — please verify the values.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Generate", style: .default) { [weak self] _ in
            self?.startGenerateValuesInTable()
        })
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
    
    private func startGenerateValuesInTable() {
        let items = comparisonEntity.itemsArray.map { $0.unwrappedName }
        let attributes = comparisonEntity.attributesArray.map { $0.unwrappedName }
        
        let loadingAlert = UIAlertController(
            title: "Generating values",
            message: "Please wait...",
            preferredStyle: .alert
        )
        present(loadingAlert, animated: true)
        
        Task {
            do {
                let matrix = try await AIAssistantService.shared.generateValuesForTable(items: items, attributes: attributes)
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) { [weak self] in
                        self?.applyGeneratedValuesToTable(matrix)
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) { [weak self] in
                        self?.showGenerateValuesError(error)
                    }
                }
            }
        }
    }
    
    private func applyGeneratedValuesToTable(_ matrix: [[Bool]]) {
        let items = comparisonEntity.itemsArray
        let attributes = comparisonEntity.attributesArray
        for (i, itemEntity) in items.enumerated() {
            guard i < matrix.count else { break }
            for (j, attrEntity) in attributes.enumerated() {
                guard j < matrix[i].count else { break }
                let valueEntity = sharedData.fetchValue(item: itemEntity, attribute: attrEntity)
                sharedData.updateComparisonValue(for: valueEntity, newValue: matrix[i][j], nil)
            }
        }
        objectTableView.reloadData()
        valuesCollectionView.reloadData()
    }
    
    private func showGenerateValuesError(_ error: Error) {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
}
