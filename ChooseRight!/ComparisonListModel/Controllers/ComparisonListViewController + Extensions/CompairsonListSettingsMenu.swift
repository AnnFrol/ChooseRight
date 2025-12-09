import UIKit

struct itemSortKeys {
    let name = "name"
    let date = "date"
    let value = "trueValuesCount"
}

extension ComparisonListViewController: UIDocumentPickerDelegate {
    
    func savePdfToUserPath(pdfURL: URL) {
        guard FileManager.default.fileExists(atPath: pdfURL.path) else {
            print ("PDF file doesn`t exist")
            return
        }
        
        
        let documentPicker = UIDocumentPickerViewController(forExporting: [pdfURL], asCopy: true)
        
//        let dodod = UIdocumpickervie
//        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true)
    }
    
//    func savePdfToUserPath(pdfURL: URL) {
//        
//        print ("SAVE PDF FETCHED")
//        let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
//        activityViewController.popoverPresentationController?.sourceView = self.presentedViewController?.view
//        self.presentedViewController?.present(activityViewController, animated: true, completion: nil)
//
//    }

    

    
    func  setupSettingsMenu() -> UIMenu {
        var menu = UIMenu()
        
        let downloadPDFAction = UIAction(title: "Download PDF", handler: { _ in
            
            //            var values = self.comparisonValuesFetchResultsController.fetchedObjects
            //            values?.forEach({ value in
            //                self.sharedData.deleteValue(value: value)
            
            //            })
            
//            let pdfData = self.createPDFData()
//            
//            
//            let documentPath = FileManager.default.urls(
//                for: .documentDirectory,
//                in: .userDomainMask).first!
//            let pdfPath = documentPath.appendingPathComponent("CollectionView.pdf")
//            
//            do {
//                try pdfData.write(to: pdfPath)
//                print("PDF created at \(pdfPath)")
//            } catch {
//                print("Failed to save PDF")
//            }
//            
//            print("PDF")
            
            guard let pdfFile = PDFService.getPdfDocument(fetchedItems: self.comparisonItemsFetchResultsController) else { return }
            
            self.savePdfToUserPath(pdfURL: pdfFile)
            
            
            print("pdfFile")
            print(pdfFile)
            
        })
        
//        let edit = UIAction(title: "Edit", handler: { _ in
//            self.toggleWobbleAnimation()
//                        print("Edit tapped")})
        
//        let shareAppAction = UIAction(title: "Share App", handler: { _ in
//            print("Share App")})
        
        let deleteListAction = UIAction(title: "Delete list", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
            
            self.navigationController?.popViewController(animated: true)
            print("delete \(self.comparisonEntity.unwrappedName)")
            
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
//            }
            

            print("Percent")
            print(self.currentSortKey)
        })
        
        let dateSortingAction = UIAction(title: "Created", state: currentSortKey == itemSortKeys().date ? .on : .off, handler: { _ in
            
            self.updateSortKey(itemSortKeys().date)
            print("Time")
            print(self.currentSortKey)

        })
        
        let nameSortingAction = UIAction(title: "Name", state: currentSortKey == itemSortKeys().name ? .on : .off, handler: { _ in
            
            self.updateSortKey("name")
            print("Name")
            print(self.currentSortKey)
        })
        
        let sortingSubMenu = UIMenu(title: "Sort", options: .displayInline, children: [
            percentSortingAction,
            dateSortingAction,
            nameSortingAction
        ])
                
        menu = UIMenu(title: "", image: nil,children: [
            downloadPDFAction,
            deleteListAction,
            sortingSubMenu,
        ])
        
        return menu
    }
    
    //MARK setupAttributesCellMenu
    func setupAttributesCellMenu(attribute: ComparisonAttributeEntity) {
        let changeAttributesNameAction = UIAction(title: "Edit attribute", handler: { _ in
            print("Change name pressed")
        })
        
        let deleteAttributeAction = UIAction(title: "Delete attribute", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
         
            print("Delete attribute tapped")
        }
        
        attributeCellMenu = UIMenu(title: "attribute name", image: nil,
                                   children: [changeAttributesNameAction, deleteAttributeAction])
        
        
    }
}
