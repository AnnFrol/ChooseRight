//
//  PopOverCollectionView.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 14.03.2024.
//

import Foundation
import UIKit

class PopOverCollectionView: UICollectionView {
    
    private var flowLayout = UICollectionViewFlowLayout()
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
}
