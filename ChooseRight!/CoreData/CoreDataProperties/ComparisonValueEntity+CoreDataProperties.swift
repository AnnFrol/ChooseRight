//
//  ComparisonValueEntity+CoreDataProperties.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 10.07.2023.
//
//

import Foundation
import CoreData

public enum ComparisonValueState: Int16 {
    case minus = 0
    case neutral = 1
    case plus = 2
    
    var displaySymbol: String {
        switch self {
        case .minus:
            return "-"
        case .neutral:
            return "○"
        case .plus:
            return "+"
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .minus:
            return "Minus"
        case .neutral:
            return "Neutral"
        case .plus:
            return "Plus"
        }
    }
}

extension ComparisonValueEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ComparisonValueEntity> {
        return NSFetchRequest<ComparisonValueEntity>(entityName: "ComparisonValueEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var value: Bool
    @NSManaged public var isNeutral: Bool
    @NSManaged public var comment: String?
    @NSManaged public var item: ComparisonItemEntity?
    @NSManaged public var attribute: ComparisonAttributeEntity?
    @NSManaged public var comparison: ComparisonEntity?
    
    public var unwrappedComment: String {
        comment ?? "No comment"
    }
    
    public var hasComment: Bool {
        !(comment?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    public var relatedItem: ComparisonItemEntity {
        item ?? ComparisonItemEntity()
    }
    
    public var relatedAttribute: ComparisonAttributeEntity {
        attribute ?? ComparisonAttributeEntity()
    }
    
    public var booleanValue: Bool {
        value
    }
    
    public var state: ComparisonValueState {
        if isNeutral {
            return .neutral
        }
        
        return value ? .plus : .minus
    }
    
    public var effectivePositiveValue: Bool {
        state == .plus
    }
    
    public var potentialPositiveValue: Bool {
        state == .plus || state == .neutral
    }
    
    public var displaySymbol: String {
        state.displaySymbol
    }

}

extension ComparisonValueEntity : Identifiable {

}

extension ComparisonValueEntity {

    public override func didSave() {
//     item?.updateTrueValuesCount()

    }
}
