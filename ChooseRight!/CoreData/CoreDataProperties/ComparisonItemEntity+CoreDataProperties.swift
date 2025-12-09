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
    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var comparison: ComparisonEntity?
    @NSManaged public var attributes: NSSet?
    @NSManaged public var value: NSSet?

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
