//
//  ComparisonsListViewController + NSFetchResults.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 08.10.2023.
//

import UIKit
import CoreData

extension ComparisonListViewController {
    
    public func loadSavedData(itemsSortKey: String) {
        itemsFetchController(sortKey: itemsSortKey)
        attributesFetchController()
        valuesFetchController()
    }
    
    func itemsFetchController(sortKey: String) {
        if self.comparisonItemsFetchResultsController == nil || self.comparisonItemsFetchResultsController.fetchRequest.sortDescriptors?.first?.key != sortKey {
            
            var ascending = true
            
            switch sortKey {
            case itemSortKeys().date:
                ascending = true
                
            case itemSortKeys().name:
                ascending = true
                
            case itemSortKeys().value:
                ascending = false
                
            default:
                ascending = false
            }
            
            
            let request =  NSFetchRequest<ComparisonItemEntity>(entityName: "ComparisonItemEntity")
            let sort = NSSortDescriptor(key: sortKey, ascending: ascending)
            let predicate = NSPredicate(format: "comparison == %@", self.comparisonEntity)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            request.predicate = predicate
            
            
            self.comparisonItemsFetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedData.viewContext, sectionNameKeyPath: nil, cacheName: nil)

            comparisonItemsFetchResultsControllerDelegate = self
            comparisonItemsFetchResultsController.delegate = comparisonItemsFetchResultsControllerDelegate
            
        }
        do {
            try comparisonItemsFetchResultsController.performFetch()
            
            self.objectTableView.reloadData()
            self.valuesCollectionView.reloadData()
        } catch {
            print("Items fetch failed, invalid controller")
        }
    }
    
    private func attributesFetchController() {
        if self.comparisonAttributesFetchResultsController == nil {
            let request = NSFetchRequest<ComparisonAttributeEntity>(entityName: "ComparisonAttributeEntity")
            let sort = NSSortDescriptor(key: "date", ascending: false)
            let predicate = NSPredicate(format: "comparison == %@", self.comparisonEntity)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            request.predicate = predicate
            
            self.comparisonAttributesFetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedData.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            comparisonAttributesFetchResultsControllerDelegate = self
            comparisonAttributesFetchResultsController.delegate = comparisonAttributesFetchResultsControllerDelegate
        }
        do {
            try comparisonAttributesFetchResultsController.performFetch()
            
            print("Attribues count: ", comparisonAttributesFetchResultsController.fetchedObjects?.count as Any)
//            self.attributesCollectionView.reloadData()
        } catch {
            print("Attributes fetch failed, invalid controller")
        }
    }
    
    private func valuesFetchController() {
        if self.comparisonValuesFetchResultsController == nil {
            let request = NSFetchRequest<ComparisonValueEntity>(entityName: "ComparisonValueEntity")
            let sort = NSSortDescriptor(key: "item", ascending: false)
            let predicate = NSPredicate(format: "comparison == %@", self.comparisonEntity)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 60
            request.predicate = predicate
            
            self.comparisonValuesFetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedData.viewContext, sectionNameKeyPath: "item", cacheName: nil)
            
            comparisonValuesFetchResultsControllerDelegate = self
            comparisonValuesFetchResultsController.delegate = comparisonValuesFetchResultsControllerDelegate
        }
        do {
            try comparisonValuesFetchResultsController.performFetch()
            print("Values count: \(comparisonValuesFetchResultsController.fetchedObjects?.count as Any)")
//            self.valuesCollectionView.reloadData()
        } catch {
            print("Values fetch failed, invalid controller")
        }
    }
}

