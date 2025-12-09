//
//  ValuesLayout.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 01.08.2023.
//

import Foundation
import UIKit

class ValuesLayout: UICollectionViewFlowLayout {
    
    var cellWidth = 87.0
    var cellHeight = 86.0
    
    convenience init(cellWidth: Double, cellHeight: Double) {
        self.init()
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
    }
    
    var cellAttrsDictionary = Dictionary<NSIndexPath, UICollectionViewLayoutAttributes>()
    
    var contentSize = CGSize.zero
    
    override func prepare() {
        
//        let cellIndex = NSIndexPath(item: item, section: section)
        
    }
    
    override var collectionViewContentSize: CGSize {
        let height = Int(cellHeight) * (collectionView?.numberOfSections ?? 200)
        let width = Int(cellWidth) * (collectionView?.numberOfItems(inSection: 0) ?? 200)
        
        return CGSize(width: width, height: height)
    }
    
}
