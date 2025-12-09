//
//  ComparisonEntity+CoreDataProperties.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 10.07.2023.
//
//

import Foundation
import CoreData


extension ComparisonEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComparisonEntity> {
        return NSFetchRequest<ComparisonEntity>(entityName: "ComparisonEntity")
    }

    @NSManaged public var color: String?
    @NSManaged public var comment: String?
    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var items: NSSet?
    @NSManaged public var attributes: NSSet?

}

// MARK: Generated accessors for items
extension ComparisonEntity {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ComparisonItemEntity)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ComparisonItemEntity)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

// MARK: Generated accessors for attributes
extension ComparisonEntity {

    @objc(addAttributesObject:)
    @NSManaged public func addToAttributes(_ value: ComparisonAttributeEntity)

    @objc(removeAttributesObject:)
    @NSManaged public func removeFromAttributes(_ value: ComparisonAttributeEntity)

    @objc(addAttributes:)
    @NSManaged public func addToAttributes(_ values: NSSet)

    @objc(removeAttributes:)
    @NSManaged public func removeFromAttributes(_ values: NSSet)

}

extension ComparisonEntity : Identifiable {

}
