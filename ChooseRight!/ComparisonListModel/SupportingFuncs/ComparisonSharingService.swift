//
//  ComparisonSharingService.swift
//  ChooseRight!
//
//  Service for sharing comparison data via file
//

import Foundation
import UIKit
import CoreData

struct ComparisonShareData: Codable {
    let name: String
    let color: String?
    let items: [ItemShareData]
    let attributes: [AttributeShareData]
}

struct ItemShareData: Codable {
    let name: String
    let color: String?
    let values: [ValueShareData]
}

struct AttributeShareData: Codable {
    let name: String
}

struct ValueShareData: Codable {
    let attributeIndex: Int
    let value: Bool
    let comment: String?
}

class ComparisonSharingService {
    
    static let urlScheme = "chooseright"
    
    // MARK: - Create shareable file (always use file for sharing)
    static func createShareFile(from comparison: ComparisonEntity) -> URL? {
        guard let shareData = encodeComparison(comparison: comparison) else {
            return nil
        }
        
        // Convert to JSON
        guard let jsonData = try? JSONEncoder().encode(shareData) else {
            return nil
        }
        
        // Create temporary file
        let fileName = "\(comparison.unwrappedName).chooseright"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // Write data to file
        do {
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }
    
    // MARK: - Encode comparison to shareable data
    private static func encodeComparison(comparison: ComparisonEntity) -> ComparisonShareData? {
        let items = comparison.itemsArray
        let attributes = comparison.attributesArray
        
        // Encode items with their values
        var encodedItems: [ItemShareData] = []
        for item in items {
            var values: [ValueShareData] = []
            
            // Get all values for this item
            for (attrIndex, attribute) in attributes.enumerated() {
                let value = CoreDataManager.shared.fetchValue(item: item, attribute: attribute)
                values.append(ValueShareData(
                    attributeIndex: attrIndex,
                    value: value.booleanValue,
                    comment: value.unwrappedComment == "No comment" ? nil : value.unwrappedComment
                ))
            }
            
            encodedItems.append(ItemShareData(
                name: item.unwrappedName,
                color: item.color,
                values: values
            ))
        }
        
        // Encode attributes
        let encodedAttributes = attributes.map { AttributeShareData(name: $0.unwrappedName) }
        
        return ComparisonShareData(
            name: comparison.unwrappedName,
            color: comparison.color,
            items: encodedItems,
            attributes: encodedAttributes
        )
    }
    
    // MARK: - Decode and import comparison from URL or file
    static func importComparison(from url: URL) -> Bool {
        // Handle file import (.chooseright files)
        if url.pathExtension == "chooseright" {
            guard let jsonData = try? Data(contentsOf: url) else {
                return false
            }
            
            guard let shareData = try? JSONDecoder().decode(ComparisonShareData.self, from: jsonData) else {
                return false
            }
            
            return createComparison(from: shareData)
        }
        
        // Handle URL scheme
        guard url.scheme == urlScheme,
              url.host == "share",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let dataItem = queryItems.first(where: { $0.name == "data" }),
              let encodedString = dataItem.value,
              let base64String = encodedString.removingPercentEncoding,
              let jsonData = Data(base64Encoded: base64String) else {
            return false
        }
        
        guard let shareData = try? JSONDecoder().decode(ComparisonShareData.self, from: jsonData) else {
            return false
        }
        
        return createComparison(from: shareData)
    }
    
    // MARK: - Create comparison from share data
    private static func createComparison(from shareData: ComparisonShareData) -> Bool {
        let sharedDataBase = CoreDataManager.shared
        let viewContext = sharedDataBase.viewContext
        
        // Create comparison synchronously
        guard let comparisonEntityDescription = NSEntityDescription.entity(
            forEntityName: "ComparisonEntity",
            in: viewContext
        ) else {
            return false
        }
        
        let comparison = ComparisonEntity(entity: comparisonEntityDescription, insertInto: viewContext)
        comparison.id = UUID()
        comparison.name = shareData.name
        comparison.date = Date().getLocalDate()
        comparison.color = shareData.color ?? specialColors.first
        
        // Create attributes
        var createdAttributes: [ComparisonAttributeEntity] = []
        for attributeData in shareData.attributes {
            guard let attributeEntityDescription = NSEntityDescription.entity(
                forEntityName: "ComparisonAttributeEntity",
                in: viewContext
            ) else {
                continue
            }
            
            let attribute = ComparisonAttributeEntity(entity: attributeEntityDescription, insertInto: viewContext)
            attribute.id = UUID()
            attribute.name = attributeData.name
            attribute.date = Date().getLocalDate()
            attribute.comparison = comparison
            createdAttributes.append(attribute)
        }
        
        // Create items with values
        for itemData in shareData.items {
            guard let itemEntityDescription = NSEntityDescription.entity(
                forEntityName: "ComparisonItemEntity",
                in: viewContext
            ) else {
                continue
            }
            
            let item = ComparisonItemEntity(entity: itemEntityDescription, insertInto: viewContext)
            item.id = UUID()
            item.name = itemData.name
            item.color = itemData.color ?? specialColors.first
            item.date = Date().getLocalDate()
            item.comparison = comparison
            
            // Create values for item
            for valueData in itemData.values {
                if valueData.attributeIndex < createdAttributes.count {
                    let attribute = createdAttributes[valueData.attributeIndex]
                    
                    guard let valueEntityDescription = NSEntityDescription.entity(
                        forEntityName: "ComparisonValueEntity",
                        in: viewContext
                    ) else {
                        continue
                    }
                    
                    let value = ComparisonValueEntity(entity: valueEntityDescription, insertInto: viewContext)
                    value.id = UUID()
                    value.value = valueData.value
                    value.comment = valueData.comment
                    value.item = item
                    value.attribute = attribute
                    value.comparison = comparison
                }
            }
        }
        
        // Save context
        do {
            try viewContext.save()
            return true
        } catch {
            return false
        }
    }
}

