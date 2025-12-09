//
//  MainTableViewCell.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 23.04.2023.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    static let idMainTableViewCell = "idMainTableViewCell"
    
    private let backgroundCell: UIView = {
       let view = UIView()
        view.backgroundColor = .specialColors.subviewBackground
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let circleIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "elipseIcon")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .specialColors.oneBlueWinterWiazrd
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let compairsonNameLabel = UILabel(comparisonNameLabelText: "Some comparison")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
         
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        isUserInteractionEnabled = true
        layer.cornerRadius = 10
        
        addSubview(backgroundCell)
        addSubview(circleIcon)
        addSubview(compairsonNameLabel)
    }
}

//MARK: - Configure from DataModel

extension MainTableViewCell {
    public func configureCell(model: ComparisonEntity) {
        compairsonNameLabel.text = model.name
            circleIcon.tintColor = UIColor(named: model.color ?? "specialOneBlueWinterWiazrd")
    }
}


//MARK: - Set Constraints
extension MainTableViewCell {
    func setConstraints() {
        NSLayoutConstraint.activate([
            backgroundCell.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            backgroundCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundCell.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundCell.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            circleIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            circleIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleIcon.heightAnchor.constraint(equalToConstant: 29),
            circleIcon.widthAnchor.constraint(equalToConstant: 29),
            
            compairsonNameLabel.leadingAnchor.constraint(equalTo: circleIcon.trailingAnchor, constant: 16),
            compairsonNameLabel.centerYAnchor.constraint(equalTo: circleIcon.centerYAnchor),
            compairsonNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
    }
}
