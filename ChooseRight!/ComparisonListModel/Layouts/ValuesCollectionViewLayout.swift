//
//  ComparsionsListViewLayout.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 11.06.2023.
//

import Foundation
import UIKit

class ValuesCollectionViewLayout: UICollectionViewFlowLayout {
    
    
    
    var cellWidth = 86.0
    var cellHeight = 91.0
    
    var width = 86.0
    var height = 91.0
    
    
    
    convenience init(cellWidth: Double, cellHeight: Double) {
        self.init()
        self.width = cellWidth
        self.height = cellHeight
        
        
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = .zero
        estimatedItemSize = .zero
        scrollDirection = .horizontal
    }

    var cellAttrsDictionary = Dictionary<NSIndexPath, UICollectionViewLayoutAttributes>()

    var contentSize = CGSize.zero

    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }

    override func prepare() {
        
        guard let collectionView = collectionView else { return }
        
        
        if collectionView.numberOfSections > 0 {
            for section in 0..<collectionView.numberOfSections {

                if collectionView.numberOfItems(inSection: section) > 0 {
                    for item in 0..<collectionView.numberOfItems(inSection: section) {

                        //Build the UICollectionViewLayoutAttributes for the cell:
                        let cellIndex = NSIndexPath(item: item, section: section)

                        let xPos = Double(item) * cellWidth
                        let yPos = Double(section) * cellHeight

                        let cellAttributes = UICollectionViewLayoutAttributes(forCellWith:
                                                                                cellIndex as IndexPath)

                        cellAttributes.frame = CGRect(x: xPos,
                                                      y: yPos,
                                                      width: cellWidth,
                                                      height: cellHeight)

                        cellAttrsDictionary[cellIndex] = cellAttributes
                    }
                }
            }
        } else { return }

        //content size updating



            let contentWidth = Double(collectionView.numberOfItems(inSection: 0)) * self.cellWidth
            let contentHeight = Double(collectionView.numberOfSections) * self.cellHeight
            self.contentSize = CGSize(width: contentWidth,
                                      height: contentHeight)
        }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var attrsInRectArray = [UICollectionViewLayoutAttributes]()

        for cellAttributes in cellAttrsDictionary.values {
            if CGRectIntersectsRect(rect, cellAttributes.frame) {
                attrsInRectArray.append(cellAttributes)
            }
        }
        return attrsInRectArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        
        
        let attrs = UICollectionViewLayoutAttributes()
        guard let resultAttrs = cellAttrsDictionary[indexPath as NSIndexPath] else {
            return attrs
        }
        return resultAttrs

    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }


}
