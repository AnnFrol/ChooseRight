//
//  CoreDataManager.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 05.07.2023.
//

import UIKit
import CoreData

public struct ImportedTableData {
    public let items: [String]
    public let attributes: [String]
    public let values: [[String]] // values[row][column] - значения для каждого айтема
    public let firstHeader: String? // Заголовок первого столбца (если есть)
    
    public init(items: [String], attributes: [String], values: [[String]], firstHeader: String? = nil) {
        self.items = items
        self.attributes = attributes
        self.values = values
        self.firstHeader = firstHeader
    }
}

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
        let finalName = uniqueComparisonName(for: name)
        guard let comparisonEntityDescription = NSEntityDescription.entity(
            forEntityName: entity.comparison,
            in: viewContext) else {
            return nil
        }
        let date = Date().getLocalDate()
        let comparison = ComparisonEntity(entity: comparisonEntityDescription, insertInto: viewContext)
        comparison.id = UUID()
        comparison.name = finalName
        comparison.date = date
        comparison.color = color
        appDelegate.saveContext()
        return comparison.id?.uuidString
    }
    
    /// Returns a name that is not yet used; if `name` is taken, tries "name (2)", "name (3)", etc.
    private func uniqueComparisonName(for name: String) -> String {
        let allNames = fetchAllComparisons().compactMap { $0.name }
        if !allNames.contains(name) { return name }
        var n = 2
        while allNames.contains("\(name) (\(n))") { n += 1 }
        return "\(name) (\(n))"
    }
    
    
    //MARK: Read comparison
    //Fetch all comparisons
    public func fetchAllComparisons() -> [ComparisonEntity] {
        
        let fetchRequest = NSFetchRequest<ComparisonEntity>(entityName: entity.comparison)
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            // Error fetching comparisons
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.comparison)
        fetchRequest.predicate = NSPredicate(format: "name = %@", newName)
        var comparisons: [ComparisonEntity]?
        do {
            comparisons = try? viewContext.fetch(fetchRequest) as? [ComparisonEntity] ?? []
        }
        
        let count = comparisons?.count ?? 0
        
        if count > 0 {
            return false
        } else {
            //updating name
            comparison.name = newName
        }
        appDelegate.saveContext()
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
            return false
        } else {
            //updating name
            let comparison = comparisons?.first
            comparison?.name = newName
        }
        appDelegate.saveContext()
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
                
                
                guard let comparisonItemEntityDescription = NSEntityDescription.entity(forEntityName: self.entity.item, in: self.viewContext)
                else {
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
    
    /// Синхронная версия createComparisonItem для импорта данных
    @discardableResult
    private func createComparisonItemSync(name: String, relatedComparison: ComparisonEntity, color: String?) -> Bool {
        // Проверяем, не используется ли имя
        let comparisonItemNames = relatedComparison.itemsArray.map { $0.unwrappedName }
        if comparisonItemNames.contains(name) {
            return false
        }
        
        // Создаем айтем синхронно
        guard let comparisonItemEntityDescription = NSEntityDescription.entity(forEntityName: entity.item, in: viewContext) else {
            return false
        }
        
        let date = Date().getLocalDate()
        let comparisonItem = ComparisonItemEntity(entity: comparisonItemEntityDescription, insertInto: viewContext)
        comparisonItem.id = UUID()
        comparisonItem.name = name
        comparisonItem.color = color
        comparisonItem.date = date
        comparisonItem.comparison = relatedComparison
        appDelegate.saveContext()
        
        addValuesForItem(item: comparisonItem)
        
        return true
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
        
        // Очищаем имя от пробелов
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else { return nil }
        
        // Проверяем, используется ли имя (case-insensitive для надежности)
        let attributeNames = relatedComparison.attributesArray.map { 
            $0.unwrappedName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        
        if attributeNames.contains(cleanedName.lowercased()) {
            return nil
        } else {
            
            // Создаем атрибут
            guard let attributeEntityDescription = NSEntityDescription.entity(forEntityName: entity.attribute, in: viewContext) else {
                return nil
            }
            
            let date = Date().getLocalDate()
            let comparisonAttribute = ComparisonAttributeEntity(entity: attributeEntityDescription, insertInto: viewContext)
            comparisonAttribute.id = UUID()
            comparisonAttribute.name = cleanedName // Используем очищенное имя
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
                    return nil
                    }
            return attributes.first
        }
        
        
    }
    
    public func fetchComparisonAttribute(name: String, relatedComparison: ComparisonEntity) -> ComparisonAttributeEntity? {
        return fetchAttributeWithName(relatedComparison: relatedComparison, name: name)
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
    
    //MARK: Update comparisonAttribute Order
    public func updateComparisonAttributeOrder(attribute: ComparisonAttributeEntity, sourceIndex: Int, destinationIndex: Int) {
        guard let comparison = attribute.comparison else { return }
        
        // Получаем все атрибуты, отсортированные текущим образом
        var attributes = comparison.attributesArray.sorted { $0.unwrappedDate > $1.unwrappedDate }
        
        // Удаляем перемещаемый атрибут из массива
        if let index = attributes.firstIndex(of: attribute) {
            attributes.remove(at: index)
        }
        
        // Вставляем на новую позицию
        let safeDestinationIndex = min(max(0, destinationIndex), attributes.count)
        attributes.insert(attribute, at: safeDestinationIndex)
        
        // Пересчитываем даты для сохранения порядка
        // Используем текущее время как базу и вычитаем секунды для каждого следующего элемента
        // Чтобы при сортировке по убыванию даты (ascending: false) они выстроились в нужном порядке
        let baseDate = Date()
        
        for (index, attr) in attributes.enumerated() {
            // Чем меньше индекс (выше в списке), тем более поздняя дата должна быть
            // attributes[0] -> baseDate
            // attributes[1] -> baseDate - 1 sec
            // ...
            attr.date = baseDate.addingTimeInterval(-TimeInterval(index))
        }
        
        appDelegate.saveContext()
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
                return []
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
    
    //MARK: Update Value
    public func updateValue(value: ComparisonValueEntity, booleanValue: Bool) {
        value.value = booleanValue
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
            _ = createComparisonValue(item: item, attribute: attribute)
            appDelegate.saveContext()
        }
    }
    
    func addValuesForAttribute(attribute: ComparisonAttributeEntity) {
        guard let items = attribute.comparison?.itemsArray as? [ComparisonItemEntity] else {
            return
        }
        for item in items {
            _ = createComparisonValue(item: item, attribute: attribute)
        }
    }
}

//MARK: - Table Import
extension CoreDataManager {
    
    /// Импортирует таблицу в сравнение
    /// - Parameters:
    ///   - comparison: Сравнение, в которое импортируются данные
    ///   - data: Данные таблицы (айтемы, атрибуты, значения)
    /// - Returns: Кортеж с количеством созданных айтемов и атрибутов
    @discardableResult
    public func importTableData(
        to comparison: ComparisonEntity,
        data: ImportedTableData
    ) -> (itemsCount: Int, attributesCount: Int) {
        
        var createdAttributes: [ComparisonAttributeEntity] = []
        var createdItems: [ComparisonItemEntity] = []
        
        // 1. Создаем атрибуты (если их еще нет)
        // Важно: используем синхронную версию для импорта, чтобы сохранить порядок
        // Обновляем контекст перед проверкой
        viewContext.refresh(comparison, mergeChanges: true)
        
        for attributeName in data.attributes {
            // Очищаем имя атрибута от пробелов
            let cleanedName = attributeName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanedName.isEmpty else { continue }
            
            // Проверяем существующие атрибуты (case-insensitive сравнение для надежности)
            let existingAttributes = comparison.attributesArray.filter { 
                $0.unwrappedName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == cleanedName.lowercased()
            }
            
            if let existing = existingAttributes.first {
                // Используем существующий атрибут
                createdAttributes.append(existing)
            } else {
                // Создаем новый атрибут синхронно (используем createAndGetComparisonAttribute)
                if let newAttribute = createAndGetComparisonAttribute(name: cleanedName, relatedComparison: comparison) {
                    // НЕ вызываем addValuesForAttribute здесь, так как значения будут созданы позже
                    // в цикле установки значений, и это позволит установить правильные значения из data.values
                    createdAttributes.append(newAttribute)
                    // Обновляем контекст после создания, чтобы изменения были видны
                    viewContext.refresh(comparison, mergeChanges: true)
                }
            }
        }
        
        // 2. Создаем айтемы (если их еще нет)
        // Генерируем разные цвета для каждого нового айтема
        var colorIndex = 0
        
        for itemName in data.items {
            // Обновляем контекст перед проверкой существующих айтемов
            viewContext.refresh(comparison, mergeChanges: true)
            
            let existingItems = comparison.itemsArray.filter { $0.unwrappedName == itemName }
            
            if let existing = existingItems.first {
                createdItems.append(existing)
            } else {
                // Генерируем цвет для нового айтема (циклически используем доступные цвета)
                let itemColor = specialColors[colorIndex % specialColors.count]
                colorIndex += 1
                
                // Создаем новый айтем синхронно (для импорта)
                // Сначала создаем айтем напрямую, чтобы получить ссылку на него
                guard let comparisonItemEntityDescription = NSEntityDescription.entity(forEntityName: entity.item, in: viewContext) else {
                    continue // Пропускаем, если не удалось создать описание
                }
                
                let date = Date().getLocalDate()
                let comparisonItem = ComparisonItemEntity(entity: comparisonItemEntityDescription, insertInto: viewContext)
                comparisonItem.id = UUID()
                comparisonItem.name = itemName
                comparisonItem.color = itemColor
                comparisonItem.date = date
                comparisonItem.comparison = comparison
                
                // Сохраняем контекст
                appDelegate.saveContext()
                
                // Добавляем значения для айтема
                addValuesForItem(item: comparisonItem)
                
                // Добавляем созданный айтем в список
                createdItems.append(comparisonItem)
            }
        }
        
        // 3. Устанавливаем значения для айтемов
        // Важно: используем порядок из data.items, а не из createdItems
        for (dataIndex, itemName) in data.items.enumerated() {
            guard dataIndex < data.values.count else { continue }
            
            // Находим соответствующий айтем по имени
            guard let item = createdItems.first(where: { $0.unwrappedName == itemName }) else { continue }
            
            let itemValues = data.values[dataIndex]
            
            for (attrIndex, attribute) in createdAttributes.enumerated() {
                guard attrIndex < itemValues.count else { continue }
                
                // Очищаем значение от всех пробелов и невидимых символов
                var valueText = itemValues[attrIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                valueText = valueText.replacingOccurrences(of: "\u{200B}", with: "") // Zero-width space
                valueText = valueText.replacingOccurrences(of: "\u{FEFF}", with: "") // Zero-width no-break space
                valueText = valueText.replacingOccurrences(of: "\u{00A0}", with: "") // Non-breaking space
                valueText = valueText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let boolValue = parseBooleanValue(valueText)
                
                // Получаем или создаем значение
                var value = fetchValue(item: item, attribute: attribute)
                
                // Проверяем, существует ли значение (проверяем по item, так как fetchValue может вернуть пустой объект)
                // id не опциональный, поэтому проверяем через item
                let valueExists = value.item != nil
                
                // Если значение не существует, создаем его
                if !valueExists {
                    _ = createComparisonValue(item: item, attribute: attribute)
                    value = fetchValue(item: item, attribute: attribute)
                }
                
                // Устанавливаем значение (даже если оно только что создано с false, обновим его на правильное)
                updateValue(value: value, booleanValue: boolValue)
            }
        }
        
        return (itemsCount: createdItems.count, attributesCount: createdAttributes.count)
    }
    
    /// Преобразует текстовое значение в boolean
    private func parseBooleanValue(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespaces)
        
        // Пустые значения = false
        if normalized.isEmpty {
            return false
        }
        
        // Отрицательные значения (явно обрабатываем)
        let negativeValues = ["-", "нет", "no", "0", "false", "✗", "✕", "x", "n", "отсутствует"]
        if negativeValues.contains(normalized.lowercased()) {
            return false
        }
        
        // Положительные значения
        let positiveValues = ["+", "да", "yes", "1", "true", "✓", "✔", "v", "y", "есть"]
        
        return positiveValues.contains(normalized.lowercased())
    }
}

