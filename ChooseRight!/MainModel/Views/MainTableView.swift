//
//  MainTableView.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 23.04.2023.
//

import UIKit

class MainTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configure()
        register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.idMainTableViewCell)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        isUserInteractionEnabled = true
        backgroundColor = .clear
        //        separatorStyle = .none
        showsVerticalScrollIndicator = false
        bounces = true
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        
        separatorStyle = .singleLine
        separatorColor = .clear
        separatorInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
}



