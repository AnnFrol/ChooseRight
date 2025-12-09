//
//  AttributesTableView.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 04.04.2023.
//

import UIKit


class AttributesTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func configure() {
        bounces = false
        backgroundColor = .clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
    }
}
