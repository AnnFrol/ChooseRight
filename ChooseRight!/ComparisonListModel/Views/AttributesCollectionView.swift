//
//  AttributesCollectionView.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 11.06.2023.
//

import Foundation
import UIKit

class AttributesCollectionView: UICollectionView {
    
    let myLayout = UICollectionViewFlowLayout()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: myLayout)
        
        setupLayout()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .clear
        bounces = true
        clipsToBounds = true
        showsHorizontalScrollIndicator = false
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLayout() {
        myLayout.minimumLineSpacing = 0
        myLayout.scrollDirection = .horizontal
        myLayout.itemSize = CGSize(width: 87,
                                   height: 50)  //need to manage (make public let somwhere)
    }
}
