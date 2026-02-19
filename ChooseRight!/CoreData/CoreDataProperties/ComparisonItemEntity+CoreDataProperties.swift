//
//  ComparisonItemEntity+CoreDataProperties.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 10.07.2023.
//
//

import Foundation
import CoreData


extension ComparisonItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComparisonItemEntity> {
        return NSFetchRequest<ComparisonItemEntity>(entityName: "ComparisonItemEntity")
    }

    @NSManaged public var color: String?
    @NSManaged public var comment: String?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var comparison: ComparisonEntity?
    @NSManaged public var attributes: NSSet?
    @NSManaged public var value: NSSet?
    
    @NSManaged public var trueValuesCount: Int16
    
//    @NSManaged public var rate: Int
    
    public var unwrappedName: String {
        name ?? "Unknown item"
    }
    public var unwrappedDate: Date {
        date ?? Date().getLocalDate()
    }
    public var attributesArray: [ComparisonAttributeEntity] {
        let attributesSet = attributes as? Set<ComparisonAttributeEntity> ?? []
        return attributesSet.sorted { $0.unwrappedDate > $1.unwrappedDate }
    }
    
    public var getPlusesAndValues: [Int] {
        var pluse = 0
        let values = value as? Set<ComparisonValueEntity> ?? []
        
        for value in values {
            if value.booleanValue == true {
                pluse += 1
            }
        }

        return [pluse, values.count]
    }
    
    public var getRelevance: Int {
        
        let plusesAndValues = getPlusesAndValues
        
        let pluses = Double(plusesAndValues[0])
        let values = Double(plusesAndValues[1])
        
        let relevance = (pluses / values) * 100

        if values != 0.0 { return Int(relevance)}
        else { return 0 }
        }

}

// MARK: Generated accessors for attributes
extension ComparisonItemEntity {

    @objc(addAttributesObject:)
    @NSManaged public func addToAttributes(_ value: ComparisonAttributeEntity)

    @objc(removeAttributesObject:)
    @NSManaged public func removeFromAttributes(_ value: ComparisonAttributeEntity)

    @objc(addAttributes:)
    @NSManaged public func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged public func removeFromAttributes(_ values: NSSet)

}

// MARK: Generated accessors for value
extension ComparisonItemEntity {

    @objc(addValueObject:)
    @NSManaged public func addToValue(_ value: ComparisonValueEntity)

    @objc(removeValueObject:)
    @NSManaged public func removeFromValue(_ value: ComparisonValueEntity)

    @objc(addValue:)
    @NSManaged public func addToValue(_ values: NSSet)

    @objc(removeValue:)
    @NSManaged public func removeFromValue(_ values: NSSet)

}

extension ComparisonItemEntity : Identifiable {

}

extension ComparisonItemEntity {
    func updateTrueValuesCount() {
        let valuesSet = value as? Set<ComparisonValueEntity> ?? []
        
        trueValuesCount = Int16(valuesSet.filter {$0.booleanValue}.count)
    }
}
