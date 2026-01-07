//import UIKit
//import CoreData
//
//extension ComparisonListViewController: NSFetchedResultsControllerDelegate {
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        if controller == comparisonItemsFetchResultsController {
//            switch type {
//            case .insert:
//                if let newIndexPath = newIndexPath {
//                    self.objectTableView.insertSections([newIndexPath.section], with: .fade)
//                    //                        self.objectTableView.insertItems(at: [newIndexPath])
//                    valuesCollectionView.insertSections(IndexSet(integer: newIndexPath.section))
//                }
//            case .delete:
//                if let indexPath = indexPath {
//                    //                        self.objectTableView.deleteItems(at: [indexPath])
//                    self.objectTableView.deleteSections([indexPath.section], with: .fade)
//                    valuesCollectionView.deleteSections(IndexSet(integer: indexPath.section))
//                }
//            case .update:
//                if let indexPath = indexPath {
//                    //                        self.objectTableView.reloadItems(at: [indexPath])
//                    self.objectTableView.reloadSections([indexPath.section], with: .fade)
//                }
//            case .move:
//                if let indexPath = indexPath, let newIndexPath = newIndexPath {
//                    //                        self.objectTableView.moveItem(at: indexPath, to: newIndexPath)
//                    self.objectTableView.moveSection(indexPath.section, toSection: newIndexPath.section)
//                    valuesCollectionView.moveSection(indexPath.section, toSection: newIndexPath.section)
//                }
//            @unknown default:
//                fatalError()
//            }
//        } else if controller == comparisonAttributesFetchResultsController {
//            switch type {
//            case .insert:
//                if let newIndexPath = newIndexPath {
//                    attributesCollectionView.insertItems(at: [newIndexPath])
//                    valuesCollectionView.performBatchUpdates {
//                        for section in 0..<valuesCollectionView.numberOfSections {
//                            let indexPath = IndexPath(item: newIndexPath.item, section: section)
//                            valuesCollectionView.insertItems(at: [indexPath])
//                        }
//                    }
//                }
//            case .delete:
//                if let indexPath = indexPath {
//                    attributesCollectionView.deleteItems(at: [indexPath])
//                    valuesCollectionView.performBatchUpdates {
//                        for section in 0..<valuesCollectionView.numberOfSections {
//                            let indexPath = IndexPath(item: indexPath.item, section: section)
//                            valuesCollectionView.deleteItems(at: [indexPath])
//                        }
//                    }
//                }
//            case .update:
//                if let indexPath = indexPath {
//                    attributesCollectionView.reloadItems(at: [indexPath])
//                }
//            case .move:
//                if let indexPath = indexPath, let newIndexPath = newIndexPath {
//                    attributesCollectionView.moveItem(at: indexPath, to: newIndexPath)
//                    valuesCollectionView.performBatchUpdates {
//                        for section in 0..<valuesCollectionView.numberOfSections {
//                            valuesCollectionView.moveItem(at: IndexPath(item: indexPath.item, section: section), to: IndexPath(item: newIndexPath.item, section: section))
//                        }
//                    }
//                }
//            @unknown default:
//                fatalError()
//            }
//        } 
////            else if controller == comparisonValuesFetchResultsController {
////            switch type {
////            case .insert:
////                if let newIndexPath = newIndexPath {
////                    valuesCollectionView.insertItems(at: [newIndexPath])
////                }
////            case .delete:
////            case .move:
////            case .update:
////            @unknown default:
////                break
////            }
////            
////        }
//        
//    }
//}



//
//  ComparisonListViewController + NSFetchedResultsControllerDelegate.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 18.10.2023.
//

import UIKit
import CoreData

extension ComparisonListViewController: NSFetchedResultsControllerDelegate {
    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        objectTableView.beginUpdates()
//        attributesCollectionView.performBatchUpdates( {
//            attributesCollectionView.collectionViewLayout.invalidateLayout()
//        }, completion: nil)    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        objectTableView.beginUpdates()
        attributesCollectionView.performBatchUpdates(nil, completion: nil)
//        valuesCollectionView.performBatchUpdates(nil, completion: nil)
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch controller {
            
        case self.comparisonItemsFetchResultsController :
            switch type {
                
            case.insert:
                if let newIndexPath = newIndexPath {
                    objectTableView.insertSections([newIndexPath.section], with: .fade)
                    
                    
//                    valuesCollectionView.insertItems(at: [valuesIndexPath])
//                    valuesCollectionView.insertSections(IndexSet(integer: newIndexPath.section))
//                    valuesCollectionView.reloadSections(IndexSet(integer: newIndexPath.section))
//                    valuesCollectionView.reloadData()

                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    self.objectTableView.reloadData()
//                    self.valuesCollectionView.reloadData()
//                }
                
            case .delete:
                if self.comparisonEntity.isDeleted {
                    self.comparisonItemsFetchResultsController.delegate = nil // needs to double check!
                } else {
                    if let indexPath = indexPath {
                        objectTableView.deleteSections([indexPath.section], with: .fade)
//                        valuesCollectionView.deleteSections(IndexSet(integer: indexPath.section))
//                        valuesCollectionView.reloadData()
                        objectTableView.reloadData()
                    }
                }
                
            case .move:
                
                if let indexPath = indexPath, let newIndexPath = newIndexPath {
                    
                    objectTableView.moveSection(indexPath.section, toSection: newIndexPath.section)
//                    valuesCollectionView.moveSection(indexPath.section, toSection: newIndexPath.section)
                }
//
                objectTableView.reloadData()
//                    valuesCollectionView.reloadData()
            
            case .update:
//                if let indexPath = indexPath {
//                    objectTableView.reloadSections([indexPath.section], with: .fade)
//                    valuesCollectionView.reloadSections(IndexSet(integer: indexPath.section))
                    objectTableView.reloadData()
//                    valuesCollectionView.reloadData()
//                }
                break
            @unknown default:
                break
            }
            
            
        case self.comparisonAttributesFetchResultsController :
            
            switch type {
                
            case .insert:
                if let newIndexPath = newIndexPath {
                    self.attributesCollectionView.insertItems(at: [newIndexPath])
//                    self.valuesCollectionView.reloadData()
                    
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.valuesCollectionView.reloadData()
//                    }
//                    self.valuesCollectionView.reloadData()
                    
//                    self.valuesCollectionView.performBatchUpdates {
////                        for section in 0..<valuesCollectionView.numberOfSections {
////                            let indexPath = IndexPath(item: newIndexPath.item, section: section)
////                            valuesCollectionView.insertItems(at: [indexPath])
//                        self.valuesCollectionView.reloadData()
//
////                        }
//                    }
                }
                
            case .delete:
                if self.comparisonEntity.isDeleted {
                    self.comparisonAttributesFetchResultsController.delegate = nil } else {
                        if let indexPath = indexPath {
                            
                            //                    attributesCollectionView.reloadData()
                            
                            attributesCollectionView.deleteItems(at: [indexPath])
                            //                    self.valuesCollectionView.reloadData()
                            
                            
                            //                    valuesCollectionView.performBatchUpdates {
                            //                        for section in 0..<valuesCollectionView.numberOfSections {
                            //                            let indexPath = IndexPath(item: indexPath.item, section: section)
                            //                            valuesCollectionView.deleteItems(at: [indexPath])
                            //                        }
                            //                    }
                        }
                    }
            case .move:
//                if let indexPath = indexPath, let newIndexPath = newIndexPath {
//                    attributesCollectionView.moveItem(at: indexPath, to: newIndexPath)
                self.attributesCollectionView.reloadData()
                
                
//                    self.valuesCollectionView.reloadData()

                    
//                    valuesCollectionView.performBatchUpdates {
//                        for section in 0..<valuesCollectionView.numberOfSections {
//                            valuesCollectionView.moveItem(at: IndexPath(item: indexPath.item, section: section), to: IndexPath(item: newIndexPath.item, section: section))
//                        }
//                    }
//                }
            case .update: 
                if let indexPath = indexPath {
                    self.attributesCollectionView.reloadItems(at: [indexPath])
//                    self.valuesCollectionView.reloadData()
                }
            @unknown default:
                fatalError()
            }
            
//        case self.comparisonValuesFetchResultsController :
//            switch type {
//                
//            case .insert:
//                if let newIndexPath = newIndexPath {
//                    valuesCollectionView.insertItems(at: [newIndexPath])
//                }
//                
//            case .delete:
//                if let indexPath = indexPath {
//                    valuesCollectionView.deleteItems(at: [indexPath])
//                }
//                
//            case .move:
//                if let indexPath = indexPath, let newIndexPath = newIndexPath {
//                    valuesCollectionView.moveItem(at: indexPath, to: newIndexPath)
//                }
//                    
//            case .update:
//                if let indexPath = indexPath {
//                    valuesCollectionView.reloadItems(at: [indexPath])
//                }
//            @unknown default:
//                fatalError()
//            }
//            switch type {
//                
//            case .insert:
//                if let newIndexPath = newIndexPath {
//                    attributesCollectionView.insertItems(at: [newIndexPath])
//                    
//                    let valuesPath = newIndexPath
//                    valuesCollectionView.insertItems(at: [newIndexPath])
//                    valuesCollectionView.reloadData()
//                }
//                
//            case .delete:
//                if comparisonEntity.isDeleted { break } else {
//                    
//                    if let indexPath = indexPath {
//                        let cell = attributesCollectionView.cellForItem(at: indexPath) as? AttributesCollectionViewCell
//                        cell?.removeInteraction(UIContextMenuInteraction(delegate: self))
//                        attributesCollectionView.deleteItems(at: [indexPath])
//                        valuesCollectionView.reloadData()
//                    }
//                }
//                
//            case .move:
//                attributesCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
//                
//            case .update:
//                if comparisonEntity.isDeleted { break } else {
//                    attributesCollectionView.reloadItems(at: [indexPath!])
//                    
//                }
//                
//            @unknown default:
//                break
//            }
            
            
            case self.comparisonValuesFetchResultsController:
            switch type {
                
            case .insert:
                break
//                if let newIndexPath = newIndexPath {
//                    valuesCollectionView.insertItems(at: [newIndexPath])
//                }
            case .delete:
                break
//                if let indexPath = indexPath {
//                    valuesCollectionView.deleteItems(at: [indexPath])
////                    valuesCollectionView.reloadData()
//                }
            case .move:
                break
//                if let indexPath = indexPath, let newIndexPath = newIndexPath {
//                    valuesCollectionView.moveItem(at: indexPath, to: newIndexPath)
//                }
            case .update:
                break
//                if let indexPath = indexPath {
//                    self.valuesCollectionView.reloadItems(at: [indexPath])
//                }
            @unknown default:
                fatalError()
            }
            
            
        default:
            break
        }
    }
    
//    func controller(_ controller: NSFe   tchedResultsController<any NSFetchRequestResult>, didChange sectionInfo: any NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        if controller == comparisonItemsFetchResultsController {
//            switch type {
//            case .insert:
//                objectTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
//                valuesCollectionView.insertSections(IndexSet(integer: sectionIndex))
//                
//            case .delete:
//                objectTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
//                valuesCollectionView.deleteSections(IndexSet(integer: sectionIndex))
//            @unknown default:
//                break
//            }
//        } else if controller == comparisonValuesFetchResultsController {
//            switch type {
//            case .insert:
//                valuesCollectionView.insertSections(IndexSet(integer: sectionIndex))
//            case .delete:
//                valuesCollectionView.deleteSections(IndexSet(integer: sectionIndex))
//            default:
//                break
//            }
//        }
//    }
    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        objectTableView.endUpdates()
////        attributesCollectionView.performBatchUpdates( {
////            attributesCollectionView.collectionViewLayout.invalidateLayout()
////        }, completion: nil)
//        attributesCollectionView.performBatchUpdates {
//            attributesCollectionView.reloadData()
//        }
//    }
//    
    
    
    
    
    
    
    
    
    
    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//            switch controller {
//            case self.comparisonItemsFetchResultsController:
//                self.objectTableView.beginUpdates()
//                self.valuesCollectionView.reloadData()
//            case self.comparisonAttributesFetchResultsController:
//                attributesCollectionView.performBatchUpdates {
//                    attributesCollectionView.collectionViewLayout.invalidateLayout()
//                    valuesCollectionView.reloadData()
//                }
//            default:
//            }
//            
//            
//            objectTableView.beginUpdates()
//            attributesCollectionView.performBatchUpdates( {
//                attributesCollectionView.collectionViewLayout.invalidateLayout()
//            }, completion: nil)    }
//    }
    
    
    
    
    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        switch controller {
//        case self.comparisonItemsFetchResultsController:
//            objectTableView.endUpdates()
//        case self.comparisonAttributesFetchResultsController:
//            self.attributesCollectionView.performBatchUpdates {
//                attributesCollectionView.collectionViewLayout.invalidateLayout()
//                attributesCollectionView.reloadData()
//                valuesCollectionView.reloadData()
//                objectTableView.reloadData()
//            } completion: { _ in
//            }
//
//        default:
//        }
//    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        objectTableView.endUpdates()
        attributesCollectionView.performBatchUpdates(nil, completion: nil)
//        
//        self.valuesCollectionView.reloadData()
//        self.valuesCollectionView.performBatchUpdates(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.valuesCollectionView.reloadData()
            self.valuesCollectionView.performBatchUpdates(nil)
        }
//        valuesCollectionView.performBatchUpdates(nil, completion: nil)
    }
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//        case .insert:
//            attributesCollectionView.insertSections(IndexSet(integer: sectionIndex))
//        case .delete:
//            attributesCollectionView.deleteSections(IndexSet(integer: sectionIndex))
//        default:
//            break
//        }
//    }
}
