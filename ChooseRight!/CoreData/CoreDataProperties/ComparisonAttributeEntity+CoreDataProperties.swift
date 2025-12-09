//
//  ComparisonAttributeEntity+CoreDataProperties.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 10.07.2023.
//
//

import Foundation
import CoreData


extension ComparisonAttributeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComparisonAttributeEntity> {
        return NSFetchRequest<ComparisonAttributeEntity>(entityName: "ComparisonAttributeEntity")
    }

    @NSManaged public var comment: String?
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var item: ComparisonItemEntity?
    @NSManaged public var comparison: ComparisonEntity?
    @NSManaged public var value: NSSet?

}

// MARK: Generated accessors for value
extension ComparisonAttributeEntity {

    @objc(addValueObject:)
    @NSManaged public func addToValue(_ value: ComparisonValueEntity)

    @objc(removeValueObject:)
    @NSManaged public func removeFromValue(_ value: ComparisonValueEntity)

    @objc(addValue:)
    @NSManaged public func addToValue(_ values: NSSet)

    @objc(removeValue:)
    @NSManaged public func removeFromValue(_ values: NSSet)

}

extension ComparisonAttributeEntity : Identifiable {

}
