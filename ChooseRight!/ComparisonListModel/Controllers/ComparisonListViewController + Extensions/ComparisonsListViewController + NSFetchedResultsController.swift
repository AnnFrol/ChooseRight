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
        if itemsSortKey == itemSortKeys().value {
            comparisonEntity.itemsArray.forEach { $0.updateTrueValuesCount() }
        }
        itemsFetchController(sortKey: itemsSortKey)
        attributesFetchController()
        valuesFetchController()
    }
    
    func itemsFetchController(sortKey: String) {
        let predicate = NSPredicate(format: "comparison == %@", self.comparisonEntity)
        let currentPredicateDescription = self.comparisonItemsFetchResultsController?.fetchRequest.predicate?.predicateFormat
        let needsNewController =
            self.comparisonItemsFetchResultsController == nil ||
            self.comparisonItemsFetchResultsController.fetchRequest.sortDescriptors?.first?.key != sortKey ||
            currentPredicateDescription != predicate.predicateFormat
        
        if needsNewController {
            
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
            
            if sortKey == itemSortKeys().value {
                let primarySort = NSSortDescriptor(key: itemSortKeys().value, ascending: false)
                let secondarySort = NSSortDescriptor(key: "potentialTrueValuesCount", ascending: false)
                let fallbackSort = NSSortDescriptor(key: "date", ascending: true)
                request.sortDescriptors = [primarySort, secondarySort, fallbackSort]
            } else {
                let sort = NSSortDescriptor(key: sortKey, ascending: ascending)
                request.sortDescriptors = [sort]
            }
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
        }
    }
    
    private func attributesFetchController() {
        let predicate = NSPredicate(format: "comparison == %@", self.comparisonEntity)
        let currentPredicateDescription = self.comparisonAttributesFetchResultsController?.fetchRequest.predicate?.predicateFormat
        
        if self.comparisonAttributesFetchResultsController == nil || currentPredicateDescription != predicate.predicateFormat {
            let request = NSFetchRequest<ComparisonAttributeEntity>(entityName: "ComparisonAttributeEntity")
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            request.predicate = predicate
            
            self.comparisonAttributesFetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedData.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            comparisonAttributesFetchResultsControllerDelegate = self
            comparisonAttributesFetchResultsController.delegate = comparisonAttributesFetchResultsControllerDelegate
        }
        do {
            try comparisonAttributesFetchResultsController.performFetch()
            
//            self.attributesCollectionView.reloadData()
        } catch {
        }
    }
    
    private func valuesFetchController() {
        let predicate = NSPredicate(format: "comparison == %@", self.comparisonEntity)
        let currentPredicateDescription = self.comparisonValuesFetchResultsController?.fetchRequest.predicate?.predicateFormat
        
        if self.comparisonValuesFetchResultsController == nil || currentPredicateDescription != predicate.predicateFormat {
            let request = NSFetchRequest<ComparisonValueEntity>(entityName: "ComparisonValueEntity")
            let sort = NSSortDescriptor(key: "item", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 60
            request.predicate = predicate
            
            self.comparisonValuesFetchResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedData.viewContext, sectionNameKeyPath: "item", cacheName: nil)
            
            comparisonValuesFetchResultsControllerDelegate = self
            comparisonValuesFetchResultsController.delegate = comparisonValuesFetchResultsControllerDelegate
        }
        do {
            try comparisonValuesFetchResultsController.performFetch()
//            self.valuesCollectionView.reloadData()
        } catch {
        }
    }
}

