//
////  PopOverMenuCollectionViewCell.swift
////  ChooseRight!
////
////  Created by Александр Фрольцов on 20.04.2023.
////
//
import UIKit


class PopOverMenuCollectionViewCell: UICollectionViewCell {
    
    private var selectedIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "checkIcon")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .specialTextColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var menuLabel = UILabel(popOverMenuLabelText: "Menu Text")
    
    private var arrowDownIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowDown")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .specialTextColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var arrowRightIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "arrowRight")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .specialTextColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
}
