//
//  ComparisonValueEntity+CoreDataProperties.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 10.07.2023.
//
//

import Foundation
import CoreData


extension ComparisonValueEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComparisonValueEntity> {
        return NSFetchRequest<ComparisonValueEntity>(entityName: "ComparisonValueEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var value: Bool
    @NSManaged public var comment: String?
    @NSManaged public var item: ComparisonItemEntity?
    @NSManaged public var attribute: ComparisonAttributeEntity?

}

extension ComparisonValueEntity : Identifiable {

}
