//
//  CreatePDF.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 28.05.2024.
//

import Foundation
import UIKit
import PDFKit

extension ComparisonListViewController {
    
    func createPDFData() -> Data {
        
        let myData = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        let pdfMetaData = [
            kCGPDFContextCreator: "Choose Right!",
            kCGPDFContextAuthor: "Comparison Name",
            kCGPDFContextTitle: "Comparison PDF"
            ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = self.valuesCollectionView.frame.width + self.objectTableView.frame.width
        let pageHeight: CGFloat = 210
        let pageSize = CGSize(width: pageWidth, height: pageHeight)
        let leadingPosition: CGFloat = 30
        
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: CGPoint(x: -leadingPosition, y: 30), size: pageSize), format: format)
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            var yOffset: CGFloat = 0
            let margin: CGFloat = 20
            
            for item in myData {
                if yOffset + 50 + margin * 2 > pageHeight {
                    print("page is full. New page begins")
                    context.beginPage()
                    yOffset = 0
                }
                
                
                
                let frame = CGRect(
                    x: margin,
                    y: yOffset + margin,
                    width: pageWidth - leadingPosition * 2,
                    height: 50)
                let label = UILabel(frame: frame)
                label.text = item
                label.backgroundColor = .lightGray
                label.textAlignment = .center
                
                label.layer.render(in: context.cgContext)
                
                yOffset += 50 + margin
                
                print("yOffset = \(yOffset), page height = \(pageHeight)")
                context.beginPage()
        
        
            }
        }
        
        
        
        
        
        
        
        
        
//        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842)) // A4 paper size
//        
//        let data = pdfRenderer.pdfData { context in
//            
//            context.beginPage()
//            
//            let attributes = [
//                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 72)
//            ]
//            // adding text to pdf
//            let text = "I'm a PDF!"
//            text.draw(at: CGPoint(x: 20, y: 50), withAttributes: attributes)
//            
//            // adding image to pdf from assets
//            // add an image to xcode assets and rename this.
//            let appleLogo = UIImage.init(systemName: "apple.logo")
//            let appleLogoRect = CGRect(x: 20, y: 150, width: 400, height: 350)
//            appleLogo!.draw(in: appleLogoRect)
//            
//            // adding image from SF Symbols
//            let globeIcon = UIImage(systemName: "globe")
//            let globeIconRect = CGRect(x: 150, y: 550, width: 100, height: 100)
//            globeIcon!.draw(in: globeIconRect)
//        }
        
        
        
        
        
        
        
        
        
        return data
    }
    
    
    
}
