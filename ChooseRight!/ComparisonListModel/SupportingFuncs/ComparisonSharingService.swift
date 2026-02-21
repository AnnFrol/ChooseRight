//
//  ComparisonSharingService.swift
//  ChooseRight!
//
//  Service for sharing comparison data via file
//

import Compression
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
    
    /// Имя файла с данными внутри пакета .chooseright (для импорта старых пакетов)
    private static let packageDataFileName = "data.json"

    // MARK: - Create shareable file (один файл .chooseright, бинарный формат CR01)
    static func createShareFile(from comparison: ComparisonEntity) -> URL? {
        guard let shareData = encodeComparison(comparison: comparison),
              let jsonData = try? JSONEncoder().encode(shareData) else {
            return nil
        }

        let fileName = "\(comparison.unwrappedName).chooseright"
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)

        let dataToWrite: Data
        if let compressed = zlibCompress(jsonData) {
            dataToWrite = makeBinaryFormat(version: 0x01, payload: compressed)
        } else {
            dataToWrite = makeBinaryFormat(version: 0x00, payload: jsonData)
        }

        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            try dataToWrite.write(to: fileURL)
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
    
    /// Бинарный заголовок: "CR01" + 1 байт версии формата (0x00 = raw JSON, 0x01 = zlib). Файл никогда не начинается с "{".
    private static let binaryMagic = Data([0x43, 0x52, 0x30, 0x31]) // "CR01"

    private static func makeBinaryFormat(version: UInt8, payload: Data) -> Data {
        var out = binaryMagic
        out.append(version)
        out.append(payload)
        return out
    }

    private static func parseBinaryFormat(_ data: Data) -> (version: UInt8, payload: Data)? {
        guard data.count >= 5, data.prefix(4) == binaryMagic else { return nil }
        let version = data[4]
        let payload = data.dropFirst(5)
        return (version, Data(payload))
    }

    // MARK: - Buffer compression (Compression framework)
    // API: https://developer.apple.com/documentation/accelerate/compressing-and-decompressing-data-with-buffer-compression
    // COMPRESSION_ZLIB used for interoperability with non-Apple devices; scratch buffer required for encode.

    /// Проверка на zlib-сжатие (первые байты заголовка)
    private static func isZlibCompressed(_ data: Data) -> Bool {
        guard data.count >= 2 else { return false }
        let b0 = data[0], b1 = data[1]
        return b0 == 0x78 && (b1 == 0x9C || b1 == 0x01 || b1 == 0x5E || b1 == 0xDA)
    }

    /// Сжатие через compression_encode_buffer (zlib; scratch обязателен для ZLIB).
    private static func zlibCompress(_ data: Data) -> Data? {
        let srcSize = data.count
        let dstCapacity = srcSize + (srcSize / 16) + 64
        let scratchSize = compression_encode_scratch_buffer_size(COMPRESSION_ZLIB)
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: dstCapacity)
        let scratchBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: scratchSize)
        defer { destinationBuffer.deallocate(); scratchBuffer.deallocate() }
        return data.withUnsafeBytes { srcBuf in
            guard let src = srcBuf.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
            let compressedSize = compression_encode_buffer(
                destinationBuffer, dstCapacity,
                src, srcSize,
                scratchBuffer,
                COMPRESSION_ZLIB
            )
            guard compressedSize > 0 else { return nil }
            return Data(bytes: destinationBuffer, count: compressedSize)
        }
    }

    /// Распаковка через compression_decode_buffer (zlib; scratch для decode не требуется).
    private static func zlibDecompress(_ data: Data) -> Data? {
        let encodedCount = data.count
        // Достаточный запас под распакованный JSON (zlib не хранит размер, оцениваем с запасом)
        let decodedCapacity = max(encodedCount * 32, 65536)
        let decodedDestinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: decodedCapacity)
        defer { decodedDestinationBuffer.deallocate() }
        return data.withUnsafeBytes { encodedBuf in
            guard let encodedPtr = encodedBuf.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return nil }
            let decodedCharCount = compression_decode_buffer(
                decodedDestinationBuffer, decodedCapacity,
                encodedPtr, encodedCount,
                nil,
                COMPRESSION_ZLIB
            )
            guard decodedCharCount > 0 else { return nil }
            return Data(bytes: decodedDestinationBuffer, count: decodedCharCount)
        }
    }
    
    // MARK: - Import result enum
    enum ImportResult: Equatable {
        case success
        case failed(ImportError)
        
        enum ImportError: Equatable {
            case invalidFile
            case limitExceeded
            case saveError
        }
    }
    
    // MARK: - Decode and import comparison from URL or file
    static func importComparison(from url: URL) -> ImportResult {
        if url.pathExtension.lowercased() == "chooseright" {
            var hasAccess = false
            if url.isFileURL {
                hasAccess = url.startAccessingSecurityScopedResource()
            }
            defer {
                if hasAccess { url.stopAccessingSecurityScopedResource() }
            }

            let jsonData: Data?

            // 1. Проверяем, является ли URL директорией (пакетом)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
                // Это ПАКЕТ. Ищем данные внутри.
                let dataURL = url.appendingPathComponent(Self.packageDataFileName)
                jsonData = try? Data(contentsOf: dataURL)
            } else {
                // 2. Это ОДИНОЧНЫЙ ФАЙЛ (старый формат)
                guard let data = try? Data(contentsOf: url) else {
                    return .failed(.invalidFile)
                }

                // Существующая логика распаковки бинарных данных
                if let (version, payload) = parseBinaryFormat(data) {
                    if version == 0x01 {
                        jsonData = zlibDecompress(payload) ?? payload
                    } else {
                        jsonData = payload
                    }
                } else if isZlibCompressed(data) {
                    jsonData = zlibDecompress(data) ?? data
                } else {
                    jsonData = data
                }
            }

            // 3. Декодируем итоговый JSON
            guard let data = jsonData,
                  let shareData = try? JSONDecoder().decode(ComparisonShareData.self, from: data) else {
                return .failed(.invalidFile)
            }
            return createComparison(from: shareData)
        }

        // Логика для URL scheme (chooseright://share...) остается прежней
        return handleUrlScheme(url)
    }

    private static func handleUrlScheme(_ url: URL) -> ImportResult {
        guard url.scheme == urlScheme,
              url.host == "share",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let dataItem = queryItems.first(where: { $0.name == "data" }),
              let encodedString = dataItem.value,
              let base64String = encodedString.removingPercentEncoding,
              let jsonData = Data(base64Encoded: base64String) else {
            return .failed(.invalidFile)
        }
        guard let shareData = try? JSONDecoder().decode(ComparisonShareData.self, from: jsonData) else {
            return .failed(.invalidFile)
        }
        return createComparison(from: shareData)
    }
    
    // MARK: - Create comparison from share data
    private static func createComparison(from shareData: ComparisonShareData) -> ImportResult {
        let sharedDataBase = CoreDataManager.shared
        let viewContext = sharedDataBase.viewContext
        
        // Check comparison limit before creating
        // Get current comparisons count
        let currentComparisons = sharedDataBase.fetchAllComparisons()
        
        // Check if user can create comparison (subscription status should be updated on app launch)
        // Access SubscriptionManager on main actor safely
        let canCreate: Bool
        if Thread.isMainThread {
            // We're on main thread, safe to access MainActor isolated property
            canCreate = MainActor.assumeIsolated {
                SubscriptionManager.shared.canCreateComparison(freeComparisonsCount: currentComparisons.count)
            }
        } else {
            // Not on main thread - use synchronous dispatch
            canCreate = DispatchQueue.main.sync {
                SubscriptionManager.shared.canCreateComparison(freeComparisonsCount: currentComparisons.count)
            }
        }
        
        if !canCreate {
            return .failed(.limitExceeded)
        }
        
        // Create comparison synchronously
        guard let comparisonEntityDescription = NSEntityDescription.entity(
            forEntityName: "ComparisonEntity",
            in: viewContext
        ) else {
            return .failed(.saveError)
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
            return .success
        } catch {
            return .failed(.saveError)
        }
    }
}

