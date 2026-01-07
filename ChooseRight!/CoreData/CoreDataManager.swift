//
//  CoreDataManager.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 05.07.2023.
//

import UIKit
import CoreData

struct EntityNames {
    let comparison = "ComparisonEntity"
    let item = "ComparisonItemEntity"
    let attribute = "ComparisonAttributeEntity"
    let value = "ComparisonValueEntity"
}

public final class CoreDataManager: NSObject {
    
    let entity = EntityNames()
    public static let shared = CoreDataManager()
    private override init() {}
    

    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    public var viewContext: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    public var backGroundContext: NSManagedObjectContext {
        appDelegate.persistentContainer.newBackgroundContext()
    }
}

//MARK: - CRUDs for entities -
extension CoreDataManager {
    
    //    //MARK: Create
    //    public func createComp(name: String) {
    //        guard let comparisonEntityDescription = NSEntityDescription.entity(forEntityName: entity.comparison, in: viewContext) else {
    //            print("Error: comparison entity description was not created")
    //            return
    //        }
    //        let comparison
    //    }
    
    //MARK: - Comparison CRUD -
    
    //MARK: CreateComparison
    public func createComparison(name: String, color: String? = specialColors.first) -> String? {
        
        //Check if name is used
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.comparison)
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        var comparisons: [ComparisonEntity]?
        do {
            comparisons = try? viewContext.fetch(fetchRequest) as? [ComparisonEntity] ?? []
        }
        
        let count = comparisons?.count ?? 0
        if count > 0 {
            print("Name already used")
            return nil
        } else {
            //Creating comparison
            guard let comparisonEntityDescription = NSEntityDescription.entity(
                forEntityName: entity.comparison,
                in: viewContext) else {
                print("ERROR: Name unused, but create failed by another cause")
                return nil
            }
            let date = Date().getLocalDate()
            let comparison = ComparisonEntity(entity: comparisonEntityDescription, insertInto: viewContext)
            comparison.id = UUID()
            comparison.name = name
            comparison.date = date
            comparison.color = color
            appDelegate.saveContext()
            print("\(date)")
            return comparison.id?.uuidString
        }
    }
    
    
    //MARK: Read comparison
    //Fetch all comparisons
    public func fetchAllComparisons() -> [ComparisonEntity] {
        
        let fetchRequest = NSFetchRequest<ComparisonEntity>(entityName: entity.comparison)
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    //Fetch comparison with name
    public func fetchComparisonWithID( id: String) -> ComparisonEntity? {
        
        let fetchRequest = NSFetchRequest<ComparisonEntity>(entityName: entity.comparison)
        do {
            guard let comparisons = try? viewContext.fetch(fetchRequest) else { return nil }
            return comparisons.first { $0.id?.uuidString == id }
        }
    }
    
    
    //MARK: Update comparison
    public func updateComparisonName(for comparison: ComparisonEntity, newName: String) -> Bool  {
        //check if name used
        let oldName = comparison.unwrappedName
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.comparison)
        fetchRequest.predicate = NSPredicate(format: "name = %@", newName)
        var comparisons: [ComparisonEntity]?
        do {
            comparisons = try? viewContext.fetch(fetchRequest) as? [ComparisonEntity] ?? []
        }
        
        let count = comparisons?.count ?? 0
        
        if count > 0 {
            print("Name already used")
            return false
        } else {
            //updating name
            comparison.name = newName
        }
        appDelegate.saveContext()
        print("Name \(oldName) changed to \(newName)")
        return true
    }
    
    public func updateComparisonNameWith(id: String, newName: String) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.comparison)
        //Check if name is used
        fetchRequest.predicate = NSPredicate(format: "name == %@", newName)
        var comparisons: [ComparisonEntity]?
        do {
            comparisons = try? viewContext.fetch(fetchRequest) as? [ComparisonEntity] ?? []
        }
        let count = comparisons?.count ?? 0
        if count > 0 {
            print("Name already used")
            return false
        } else {
            //updating name
            let comparison = comparisons?.first
            comparison?.name = newName
        }
        appDelegate.saveContext()
        print("name changed to \(newName)")
        return true
    }
    
    public func updateComparisonColor(for comparison: ComparisonEntity ,color: String) {
        
        let newColorName = color
        comparison.color = newColorName
        appDelegate.saveContext()
        
//        let newColorIndex = specialColors.first { color in
//            true
//        }
//        print(newColorIndex! as Any)
    }
    
    
    //Delete comparison
    //MARK: Delete comparison
    public func deleteComparison(comparison: ComparisonEntity) {
        //        let id = comparison.id.uuidString
        //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.comparison)
        //        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do {
            //            guard let comparisons = try? viewContext.fetch(fetchRequest) as? [ComparisonEntity] else { return }
            viewContext.delete(comparison)
        }
        appDelegate.saveContext()
    }
    
    
    //MARK: - Comparison Item CRUD -
    //MARK: Create comparisonItem
    
    @discardableResult public func createComparisonItem(name: String, relatedComparison: ComparisonEntity, color: String? = specialColors.first, completion: ((Bool) -> Void)? = nil) -> Bool {
        
        //check if item name is used
        var nameIsAvalible = false
        let comparisonItemNames = relatedComparison.itemsArray.map { $0.unwrappedName }
        
        if comparisonItemNames.contains(name) {
            return false
            
        //creating new item
        } else {
            DispatchQueue.main.async {
                
                print("Started creating of new values")
                
                guard let comparisonItemEntityDescription = NSEntityDescription.entity(forEntityName: self.entity.item, in: self.viewContext)
                else {
                    print("Item description was not created")
                    return
                }
                
                let date = Date().getLocalDate()
                let comparisonItem = ComparisonItemEntity(entity: comparisonItemEntityDescription, insertInto: self.viewContext)
                comparisonItem.id = UUID()
                comparisonItem.name = name
                comparisonItem.color = color
                comparisonItem.date = date
                comparisonItem.comparison = relatedComparison
                self.appDelegate.saveContext()
            
                self.addValuesForItem(item: comparisonItem)
                
                nameIsAvalible = true
                completion?(nameIsAvalible)
                
            }
            return true
        }
    }
    
//    public func createAndGetComparisonItem(name: String, relatedComparison: ComparisonEntity) -> ComparisonItemEntity? {
//
//        //check if name is used
//        let comparisonItemsNames = relatedComparison.itemsArray.map { $0.unwrappedName}
//
//        if comparisonItemsNames.contains(name) {
//            return nil
//        } else {
//
//            //create item
//
//        }
        
//        return ComparisonItemEntity()
//    }
    //    }
    //    public func createNewItem(comparison: ComparisonEntity, name: String) {
    //        let newItem = ComparisonItemEntity(context: viewContext)
    //        newItem.name = name
    //        newItem.id = UUID()
    //        newItem.date = Date().getLocalDate()
    //
    //        comparison.addToItems(newItem)
    //        newItem.comparison = comparison
    //        appDelegate.saveContext()
    //        print("Creating new item")
    //    }
    
    //MARK: Read comparison item
    //Fetch all items from comparison
    public func fetchAllItemsFromComparison(relatedComparison: ComparisonEntity) -> [ComparisonItemEntity] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.item)
        fetchRequest.predicate = NSPredicate(format: "comparison == %@", relatedComparison)
        do {
            guard let items = try? viewContext.fetch(fetchRequest) as? [ComparisonItemEntity] else {
                print("fetch is nil")
                return []}
            return items
        }
    }
    
    //Fetch item with name
    public func fetchComparisonItemWithName(name: String, relatedComparison: ComparisonEntity) -> ComparisonItemEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.item)
        fetchRequest.predicate = NSPredicate(format: "name == %@ && comparison == %@",  name, relatedComparison )
        do {
            guard let items = try? viewContext.fetch(fetchRequest) as? [ComparisonItemEntity] else { return nil }
            return items.first
        }
    }
    
    //Fetch item with ID
    public func fetchItemWithID(id: String) -> ComparisonItemEntity? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.item)
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            guard let items = try? viewContext.fetch(fetchRequest) as? [ComparisonItemEntity] else { return nil }
            return items.first
        }
    }
    //MARK: Update comparison item
    //Update comparisonItemName
    @discardableResult public func updateComparisonItemName(for item: ComparisonItemEntity, newName: String) -> Bool {
        guard let relatedComparison = item.comparison else { return false }
        //        let oldName = item.unwrappedName
        let comparisonItemNames = relatedComparison.itemsArray.map { $0.unwrappedName }
        
        if comparisonItemNames.contains(newName) {
            return false
        }
        
        item.name = newName
        appDelegate.saveContext()
        return true
        
    }
    
    public func updateComparisonItemColor(for item: ComparisonItemEntity, newColor: String) {
        let newColorName = newColor
        item.color = newColorName
        appDelegate.saveContext()
    }
    
    //MARK: Delete comparison item
    //Delete comparison item
    public func deleteComparisonItem(item: ComparisonItemEntity) {
        do {
            viewContext.delete(item)
        }
        appDelegate.saveContext()
        return
    }
    
    public func deleteAllComparisonItems() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.item)
        do {
            guard let items = try? viewContext.fetch(fetchRequest) as? [ComparisonItemEntity] else { return }
            items.forEach { viewContext.delete($0) }
        }
        appDelegate.saveContext()
    }
    
    
    
    //MARK: - Comparison Attribute CRUD -
    //MARK: Create comparisonAttribute
    
    @discardableResult public func createComparisonAttribute(name: String, relatedComparison: ComparisonEntity, completion: ((Bool) -> Void)? = nil) -> Bool{
        
        //check if name is used
        
        var result = false
        let attributeNames = relatedComparison.attributesArray.map { $0.unwrappedName }
        
        if attributeNames.contains(name) {
            result = false
            return false
        } else {
            
            DispatchQueue.main.async {
                
                //create attribute
                guard let attributeEntityDescription = NSEntityDescription.entity(forEntityName: self.entity.attribute, in: self.viewContext) else {
                    print("Attribute description was not created")
                    return
                }
                
                let date = Date().getLocalDate()
                let comparisonAttribute = ComparisonAttributeEntity(entity: attributeEntityDescription, insertInto: self.viewContext)
                comparisonAttribute.id = UUID()
                comparisonAttribute.name = name
                comparisonAttribute.date = date
                comparisonAttribute.comparison = relatedComparison
                
                self.addValuesForAttribute(attribute: comparisonAttribute)
                self.appDelegate.saveContext()
                result = true
                completion?(result)
            }
            
            return true
        }
    }
    
    
    public func createAndGetComparisonAttribute(name: String, relatedComparison: ComparisonEntity) -> ComparisonAttributeEntity? {
        
        //check if name is used
        let attributeNames = relatedComparison.attributesArray.map { $0.unwrappedName }
        
        if attributeNames.contains(name) {
            return nil
        } else {
            
            //create attribute
            guard let attributeEntityDescription = NSEntityDescription.entity(forEntityName: entity.attribute, in: viewContext) else {
                print("Attribute description was not created")
                return nil
            }
            
            let date = Date().getLocalDate()
            let comparisonAttribute = ComparisonAttributeEntity(entity: attributeEntityDescription, insertInto: viewContext)
            comparisonAttribute.id = UUID()
            comparisonAttribute.name = name
            comparisonAttribute.date = date
            comparisonAttribute.comparison = relatedComparison
            appDelegate.saveContext()
            return comparisonAttribute
        }
    }
    
    //MARK: Read comparisonAttribute
    
    public func fetchAllAttributesFromComparison(relatedComparison: ComparisonEntity) -> [ComparisonAttributeEntity] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.attribute)
        fetchRequest.predicate = NSPredicate(format: "comparison == %@", relatedComparison)
        do {
            guard let attributes = try? viewContext.fetch(fetchRequest) as? [ComparisonAttributeEntity] else {
                print("fetch is nil")
                return []
            }
            return attributes
        }
    }
    
    public func fetchAttributeWithName(relatedComparison: ComparisonEntity, name: String) -> ComparisonAttributeEntity? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.attribute)
        fetchRequest.predicate = NSPredicate(format: "comparison == %@ && name == %@", relatedComparison, name)
        do {
            guard let attributes = try? viewContext.fetch(fetchRequest) as? [ComparisonAttributeEntity] else {
                print("fetch is nil")
                    return nil
                    }
            return attributes.first
        }
        
        
    }
    
    //MARK: Update comparisonAttribute
    public func updateComparisonAttributeName(for attribute: ComparisonAttributeEntity, newName: String) -> Bool {
        guard let relatedComparison = attribute.comparison else { return false }
        let attrsNames = relatedComparison.attributesArray.map { $0.unwrappedName }
        
        if attrsNames.contains(newName) {
            return false
        }
        
        attribute.name = newName
        appDelegate.saveContext()
        return true
    }
    
    //MARK: Delete comparisonAttribute
    public func deleteComparisonAttribute(attribute: ComparisonAttributeEntity) {
        do {
            viewContext.delete(attribute)
        }
        appDelegate.saveContext()
        return
    }
    
    
    
    
    //MARK: - Comparison value CRUD -
    //MARK: Create comparisonValue
    
    public func createComparisonValue(item: ComparisonItemEntity, attribute: ComparisonAttributeEntity) -> Bool {
        
        guard let attributeEntityDescription = NSEntityDescription.entity(forEntityName: entity.value, in: viewContext) else {
            print("Value attribute description wasn`t create")
            return false
        }
        
        let comparisonValue = ComparisonValueEntity(entity: attributeEntityDescription, insertInto: viewContext)
        
        comparisonValue.id = UUID()
        comparisonValue.value = false
        comparisonValue.item = item
        comparisonValue.attribute = attribute
        comparisonValue.comparison = item.comparison
        appDelegate.saveContext()
        return true
    }
    
    //MARK: Read comparison value
    public func fetchValues(relatedComparison: ComparisonEntity) -> [ComparisonValueEntity] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.value)
        let predicate = NSPredicate(format: "comparison == %@", relatedComparison)
        fetchRequest.predicate = predicate
        do {
            guard let values = try? viewContext.fetch(fetchRequest) as? [ComparisonValueEntity] else {
                print("Values fetch result is nil")
                return [ComparisonValueEntity()]
            }
            return values
        }
    }
    
    public func fetchValue(item: ComparisonItemEntity, attribute: ComparisonAttributeEntity) -> ComparisonValueEntity {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.value)
        let predicateItem = NSPredicate(format: "item == %@", item)
        let predicateAttribute = NSPredicate(format:"attribute == %@", attribute)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateItem, predicateAttribute])
        fetchRequest.predicate = compoundPredicate
        do {
            guard let value = try? viewContext.fetch(fetchRequest) as? [ComparisonValueEntity] else {
                print("fetch is nil")
                return ComparisonValueEntity()
            }
            return value.first ?? ComparisonValueEntity()
        }
    }
    
    //MARK: Update comparison value
    public func updateComparisonValue(for valueEntity: ComparisonValueEntity, newValue: Bool, _ comment: String?) {
        valueEntity.value = newValue
        
        if comment != nil && valueEntity.unwrappedComment != comment {
            valueEntity.comment = comment
        }
//        valueEntity.relatedItem.updateTrueValuesCount()
        appDelegate.saveContext()

    }
    
    //MARK: Change Boolean Value
    public func changeBooleanValue(for valueEntity: ComparisonValueEntity) {
        let value = valueEntity.value
        valueEntity.value = !value
//        valueEntity.relatedItem.updateTrueValuesCount()
        appDelegate.saveContext()

    }
    
    //MARK: Delete value
    public func deleteValue(value: ComparisonValueEntity) {
        do {
            viewContext.delete(value)
        }
        
//        value.relatedItem.updateTrueValuesCount()
        appDelegate.saveContext()
        return
    }
}

//MARK: - Adding values when items\attrs created
extension CoreDataManager {
    func addValuesForItem(item: ComparisonItemEntity) {
        guard let attributes = item.comparison?.attributesArray as? [ComparisonAttributeEntity] else {
            return
        }
        for attribute in attributes {
            let valueSavingResult = createComparisonValue(item: item, attribute: attribute)
            appDelegate.saveContext()
            print("value created: \(valueSavingResult)")
        }
    }
    
    func addValuesForAttribute(attribute: ComparisonAttributeEntity) {
        guard let items = attribute.comparison?.itemsArray as? [ComparisonItemEntity] else {
            return
        }
        for item in items {
            let valueSavingresult = createComparisonValue(item: item, attribute: attribute)
            print("value created: \(valueSavingresult)")
        }
    }
}

