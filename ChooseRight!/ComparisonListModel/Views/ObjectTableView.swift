//
//  MainTableView.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 03.04.2023.
//

import UIKit

class ObjectTableView: UITableView {
    

    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configure() {
        separatorStyle = .none
        backgroundColor = .none
        separatorColor = .none
        clipsToBounds = true
        bounces = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        translatesAutoresizingMaskIntoConstraints = false
    }
}
