//
//  MainCollectionView.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 11.06.2023.
//

import Foundation
import UIKit



class ValuesColectionView: UICollectionView{

    

    
    
//    let myLayout = ValuesCollectionViewLayout()
    
    var valuesLayout = UICollectionViewFlowLayout()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: valuesLayout)
        
        configure()
//        setupLayout()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
//        estimateSize
        
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        bounces = true
        clipsToBounds = true
    }
    
    private func setupLayout() {

//        valuesLayout = ValuesCollectionViewLayout()
//        collectionViewLayout = valuesLayout
        
    }
}


