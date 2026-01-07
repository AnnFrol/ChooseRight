//
//  PDFService.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 08.09.2024.
//

import Foundation
import TPPDF
import UIKit
import CoreData

class PDFService {
    
    
    static func getPdfDocument(fetchedItems: NSFetchedResultsController<ComparisonItemEntity>?) -> URL? {
        

        let documentSize = CGSize(width: 842,
                                  height: 595)
        let documentInsets = EdgeInsets(top: 30,
                                        left: 15,
                                        bottom: 10,
                                        right: 30)
        
        let documentLayout = PDFPageLayout(size: documentSize,
                                           margin: documentInsets,
                                           space: (header: 30, footer: 30))
        let document = PDFDocument(layout: documentLayout)
        
        guard let comparisonItemsArray = fetchedItems?.fetchedObjects as? [ComparisonItemEntity] else { return nil }
        
        guard let comparison = comparisonItemsArray.first?.comparison else { return nil }
        let comparisonName = comparison.unwrappedName
        
        let comparisonAttibutesArray: [ComparisonAttributeEntity] = comparison.attributesArray


        
        
        //MARK: Page Elements
        // Header elements
        
//        guard let headerBanner = UIImage(named: "headerBannerGroup" ) else { return nil }
        guard let headerBanner = UIImage(named: "headerAppLogo 1" ) else { return nil }


//        let headerPdfBanner = PDFImage(image: headerBanner, size: CGSize(width: 171, height: 28), quality: 1.0, options: .none)
        let headerPdfBanner = PDFImage(image: headerBanner, size: CGSize(width: 83, height: 28), quality: 1.0, options: .none)


        
        // Footer elements
        guard let footerImage = UIImage(named: "footerAppLogo 1") else { return nil }
        let footerPdfImage = PDFImage(image: footerImage, size: CGSize(width: 112 /*135*/, height: 106 /*128*/), quality: 1.0, options: .none)
        
        let footerPageNumber = NSMutableAttributedString(string: " ", attributes: [
            NSAttributedString.Key.kern: -0.13,
            NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 11) as Any,
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4159629941, green: 0.4159629941, blue: 0.4159629941, alpha: 1)
        ])

        
        
        guard let myUrl = URL(string: "https://www.google.com/") else { return nil }
        footerPdfImage.add(attribute: PDFObjectAttribute.link(url: myUrl))
        
        // Page title
        let titleText = "  \(comparisonName)"
        let attributedTitleText = NSMutableAttributedString(string: titleText, attributes: [
            NSAttributedString.Key.kern: -1,
            NSAttributedString.Key.font: UIFont(name: "SFProText-Bold", size: 24) as Any,
            NSAttributedString.Key.foregroundColor: UIColor(.black)
        ])

        let headerTextElement = PDFAttributedText(text: attributedTitleText)
        
        
        // MARK: Table DataSource
        
        var tablesArray:[PDFTable] = [PDFTable]()
        
        let splittedAttributesArray = PDFService.splitArrayIntoChunks(array: comparisonAttibutesArray, chunkSize: 8)
        print("SPLITTED:", splittedAttributesArray)
        
        for chunk in splittedAttributesArray {
            let attrsArray = chunk
                            
                guard let table = PDFService.createTableWithData(
                    itemsArray: comparisonItemsArray,
                    attrsArray: attrsArray) else { return nil}
                
                tablesArray.append(table)
        }
        
        
        
        
//        var colorCounter = 1
//        for item in comparisonItemsArray {
//            
//            let color = UIColor(named: item.color ?? "") ?? .black
//
//            
//            mainTable[rows: colorCounter...colorCounter, columns: 2..<columnsCount].allColumnsStyle = [PDFTableCellStyle(colors: (fill:color.withAlphaComponent(0.2), text: .black), font: .sfProTextMedium12() ?? .boldSystemFont(ofSize: 12))]
//            
////            mainTable[colorCounter, 1].style = PDFTableCellStyle(
////                borders: PDFTableCellBorders(left: border, right: border)
////                )
//            colorCounter += 1
//        }
        
//        mainTable.widths = [0.1]
        
        
        
        //MARK: Document Generator
        
        document.add(.footerRight, attributedText: footerPageNumber)
        
        document.add(.headerRight, image: headerPdfBanner)

        
        document.add(.contentLeft, attributedTextObject: headerTextElement)
        document.add(space: 10.0)
        
        for (index, table) in tablesArray.enumerated() {
            document.add(table: table)
            footerPageNumber.setAttributedString(NSAttributedString(string: "\(index)"))
            
            if index < tablesArray.count - 1{
                document.createNewPage()

            }
            
        }
        
        document.add(.footerLeft, image: footerPdfImage)
        
        let generator = PDFGenerator(document: document)
        let url = try? generator.generateURL(filename: "\(comparisonName).pdf")
        _ = try? generator.generateData()
        return url
    }
    
    
    
    static func createTableWithData(itemsArray: [ComparisonItemEntity], attrsArray: [ComparisonAttributeEntity?]) ->  PDFTable? {
        
        let sharedData = CoreDataManager.shared
        
        let comparisonItemsArray = itemsArray
        guard comparisonItemsArray.first?.comparison != nil else { return nil }
        
        let comparisonAttibutes = attrsArray
        
        
        let rowsCount = comparisonItemsArray.count + 1
        let columnsCount = 10 //comparisonAttibutes.count + 2
        
        let mainTable = PDFTable(rows: rowsCount,
                                 columns: columnsCount)
        
        var tabRowsContent = [[nil, nil]] as [[(any PDFTableContentable)?]]
        
            for attr in comparisonAttibutes {
                
                if let cellContent = attr?.name {
                    if cellContent.count > 30 {
                        var nameShorted = String(cellContent.prefix(36))
                        nameShorted.append("..")
                        
                        let attributedNameShorted = NSMutableAttributedString(string: nameShorted, attributes: [
                            NSAttributedString.Key.kern: -0.13,
                            NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 11) as Any,
                            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4159629941, green: 0.4159629941, blue: 0.4159629941, alpha: 1)
                        ])
                        tabRowsContent[0].append(attributedNameShorted)
                    } else {
                        
                        let attributedNameShorted = NSMutableAttributedString(string: cellContent, attributes: [
                            NSAttributedString.Key.kern: -0.13,
                            NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 11) as Any,
                            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4159629941, green: 0.4159629941, blue: 0.4159629941, alpha: 1)
                        ])
                        tabRowsContent[0].append(attributedNameShorted)
                    }
                } else {
                    tabRowsContent[0].append("***")
                }
            }
        
        while tabRowsContent[0].count < 10 {
            tabRowsContent[0].append("")
        }
            
            
            for item in comparisonItemsArray {
                let itemRelevance = item.getRelevance
//                let itemRelevanceContent: String = "\(itemRelevance)%"
                let itemRelevanceContent = NSMutableAttributedString(string:  String("\(itemRelevance)%"), attributes: [
                    NSAttributedString.Key.kern: -0.2,
                    NSAttributedString.Key.font: UIFont(name: "SFProDisplay-Heavy", size: 12) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor(.black)
                ])
                
                let itemName = NSMutableAttributedString(
                    string: item.unwrappedName , 
                    attributes: [
                    NSAttributedString.Key.kern: -0.15,
                    NSAttributedString.Key.font: UIFont(name: "SFProText-Medium", size: 12) as Any,
                    NSAttributedString.Key.foregroundColor: UIColor(.black)
                ])
                
                
                
                var rowContent = [(any PDFTableContentable)?]()
                rowContent.append(itemRelevanceContent)
                rowContent.append(itemName)
                for attribute in comparisonAttibutes {
                    let cellValue = sharedData.fetchValue(item: item, attribute: attribute ?? ComparisonAttributeEntity())
                    let cellText = cellValue.booleanValue ? "+" : "-"
                    let cellContent = NSMutableAttributedString(
                        string: cellText,
                        attributes: [
                        NSAttributedString.Key.kern: -0.1,
                        NSAttributedString.Key.font: UIFont(name: "SFProText-Medium", size: 12) as Any,
                        NSAttributedString.Key.foregroundColor: UIColor(.black)
                    ])
                    
                    rowContent.append(cellContent)

                }
                
                while rowContent.count < 10 && rowContent.count > 1 {
                    rowContent.append("")
                }

                tabRowsContent.append(rowContent)
            }
        
        
        print("TABROW\n \n \n", tabRowsContent, "\n \n \n")

        
            mainTable.content = tabRowsContent
        
//        if comparisonAttibutes.count < 8 {
//            
//            for column in columnsCount - 1...8 {
//                mainTable[column: <#T##Int#>]
//                
//            }
//            
//            
//            
//        }
//        if comparisonAttibutes.count < 8 {
////            let extraColumns = 8 - comparisonAttibutes.count
//            let columnsCount = comparisonAttibutes.count
//            
////            for column in columnsCount...8 {
//            mainTable[columns: columnsCount + 1...8].merge(
//                with: PDFTableCell(
//                    content: nil))
////            }
//                    
//        }
                    
            
        // MARK: Table Style
        
        let tableStyle = PDFTableStyle()
        tableStyle.columnHeaderStyle = PDFTableCellStyle(
            colors: (fill: .white, text: UIColor.specialColors.pdfAttributeTextColor ?? .gray),
            font: .sfProTextRegular11() ?? .boldSystemFont(ofSize: 11))
        
//        tableStyle.rowHeaderStyle = PDFTableCellStyle(
//            colors: (fill: .white, text: .black),
//            font: .SFProDisplayHeavy12() ?? .italicSystemFont(ofSize: 12))
//        tableStyle.rowHeaderCount = 1
//        
        mainTable.style = tableStyle
        
//        mainTable[rowsCount - 1, 0].style = PDFTableCellStyle(
//            colors: (fill: .white, text: .black),
//            font: .SFProDisplayHeavy12() ?? .italicSystemFont(ofSize: 12))
        
//        for row in 0..<rowsCount {
//            mainTable[row, 0].style = PDFTableCellStyle(
//                colors: (fill: .white, text: .black),
//                font: .SFProDisplayHeavy12() ?? .italicSystemFont(ofSize: 12))
//            print("ROW:", row)
//            
//            mainTable[row, 1].style = PDFTableCellStyle(
//                colors: (fill: .white, text: .black),
//                font: .sfProTextMedium12() ?? .italicSystemFont(ofSize: 12))
//            print("ROW:", row)
//        }
        
        
        
//        let styleArray = Array(repeating: [PDFTableCellStyle(
//            colors: (fill: .white, text: .black),
//            font: .SFProDisplayHeavy12() ?? .italicSystemFont(ofSize: 12))], count: rowsCount)
//        
////        mainTable[rows: 0..<rowsCount, column: 0].style = styleArray
//        
//        print(mainTable.content.count)
//        mainTable[column: 0].style = [PDFTableCellStyle(
//            colors: (fill: .white, text: .black),
//            font: .SFProDisplayHeavy12() ?? .italicSystemFont(ofSize: 12))]
        
        mainTable.padding = 1.0
        mainTable.margin = 3.0
        mainTable.showHeadersOnEveryPage = false
        
        mainTable.widths = [0.06, 0.18, 0.095, 0.095, 0.095, 0.095, 0.095, 0.095, 0.095, 0.095]
        
        return mainTable
        
    }
    
    
//    static func createTablesWithDataArray(itemsArray: [ComparisonItemEntity]) ->  [PDFTable] {
//        
//        weak var sharedData = CoreDataManager.shared
//        
//        let comparisonItemsArray = itemsArray
//        guard let comparison = comparisonItemsArray.first?.comparison else { return [] }
//        let comparisonAttibutes: [ComparisonAttributeEntity] = comparison.attributesArray
//        
//        let ramainingDataColumns = comparisonAttibutes.count
//        
//        while ramainingDataColumns > 0 {
//            let currentDataColumns = min(8, ramainingDataColumns)
//            var currentTableWidths: [Double] = []
//            
//            currentTableWidths.append(0.05)
//            currentTableWidths.append(0.2)
//        }
//        
//        let rowsCount = comparisonItemsArray.count + 1
////        let columnsCount = comparisonAttibutes.count + 2
//        let columnsCount = 10
//        
//        let mainTable = PDFTable(rows: rowsCount,
//                                 columns: columnsCount)
//
//        
//        
//        var tabRowsContent = [[nil, nil]] as [[(any PDFTableContentable)?]]
//        
//            for attr in comparisonAttibutes {
//                let cellContent = attr.unwrappedName
//                tabRowsContent[0].append(cellContent)
//            }
//            
//            
//            for item in comparisonItemsArray {
//                let itemRelevance = item.getRelevance
//                let itemRelevanceContent: String = "\(itemRelevance)%"
//                let itemName = item.unwrappedName
//                var rowContent = [(any PDFTableContentable)?]()
//                rowContent.append(itemRelevanceContent)
//                rowContent.append(itemName)
//                for attribute in comparisonAttibutes {
//                    let cellValue = sharedData?.fetchValue(item: item, attribute: attribute)
//                    let cellContent = cellValue?.booleanValue ?? false ? "+" : "-"
//                    rowContent.append(cellContent)
//                }
//                tabRowsContent.append(rowContent)
//            }
//            
//            mainTable.content = tabRowsContent
//            
//        // MARK: Table Style
//        
//        let tableStyle = PDFTableStyle()
//        tableStyle.columnHeaderStyle = PDFTableCellStyle(
//            colors: (fill: .white, text: UIColor.specialColors.pdfAttributeTextColor ?? .gray),
//            font: .sfProTextRegular11() ?? .boldSystemFont(ofSize: 11))
//        
//        tableStyle.rowHeaderStyle = PDFTableCellStyle(
//            colors: (fill: .white, text: .black),
//            font: .SFProDisplayHeavy12() ?? .italicSystemFont(ofSize: 12))
//        tableStyle.rowHeaderCount = 1
//        
//        mainTable.style = tableStyle
//        mainTable[rowsCount - 1, 0].style = PDFTableCellStyle(
//            colors: (fill: .white, text: .black),
//            font: .SFProDisplayHeavy12() ?? .italicSystemFont(ofSize: 12))
//        
//        mainTable.padding = 1.0
//        mainTable.margin = 3.0
//        mainTable.showHeadersOnEveryPage = false
//        
//        return [mainTable]
//        
//    }
    
    static func splitArrayIntoChunks(array: [ComparisonAttributeEntity], chunkSize: Int) -> [[ComparisonAttributeEntity?]] {
        
        var result: [[ComparisonAttributeEntity?]] = []
        var index = 0
        
        while index < array.count {
            
            let chunk = Array(array[index..<min(index + chunkSize, array.count)])
            
            result.append(chunk)
            index += chunkSize

        }
        return result
    }
    
//    static func createTables(array: [[ComparisonAttributeEntity?]]) -> [PDFTable?]
//    {
//        var pdfTables: [PDFTable?] = []
//        
//        for dataChunk in array {
//            let data = dataChunk
//            createTableWithData(itemsArray: [], attrsArray: data)
//        }
//        
//        
//        
//        return pdfTables
//    }
}


