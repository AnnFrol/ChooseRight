////
////  ObjectTableViewCell.swift
////  ChooseRight!
////
////  Created by Александр Фрольцов on 02.04.2023.
////
//
//import UIKit
//
//class ObjectTableViewCell: UITableViewCell {
//    
//    static let idTableViewCell = "idTableViewCell"
//    
//    private let backgroundCell: UIView = {
//        let view = UIView()
//        view.layer.cornerRadius = 10
//        view.backgroundColor = .specialSubviewBackgroundColor
//        view.clipsToBounds = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let progressLabel = UILabel(percentContainerLabelText: "40%")
//    private let objectLabel = UILabel(containerLabelText: "Celebrate at home")
//    private var labelsStackView = UIStackView()
//    
//    private let circleLayer = CAShapeLayer()
//    private let progressLabelInCircle = UILabel(percentContainerLabelText: "40%")
//    private let objectLabelInCircle = UILabel(containerLabelText: "Celebrate at home")
//    
//    
//    private let circleView: UIView = {
//       let view = UIView()
//        view.backgroundColor = .red
//        view.layer.cornerRadius = view.frame.width / 2
//        return view
//    }()
//
//    
//    
//        
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        setupViews()
//        setConstraints()
//        drawCircle()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews() {
//        backgroundColor = .clear
//        selectionStyle = .none
//        isUserInteractionEnabled = true
//        
//        addSubview(backgroundCell)
//        labelsStackView = UIStackView(arrangedSubviews: [progressLabel,
//                                                        objectLabel],
//                                      axis: .vertical,
//                                      spacing: 9)
//        labelsStackView.distribution = .equalSpacing
////        addSubview(labelsStackView)
//        isUserInteractionEnabled = true
//
//        contentView.addSubview(labelsStackView)
//    }
//}
//
//// MARK: - Animation
//
//extension ObjectTableViewCell {
//    private func drawCircle() {
//
////        let center = CGPoint(x: frame.width / 2,
////                             y: frame.height / 2)
//        let center = CGPoint(x: 28.5,
//                             y: 27.5)
//        
//
//        let endAngle = (-CGFloat.pi / 2)
//        let startAngle = 2 * CGFloat.pi + endAngle
//
//        let circularPath = UIBezierPath(arcCenter: center,
//                                        radius: 35,
//                                        startAngle: startAngle,
//                                        endAngle: endAngle,
//                                        clockwise: false)
//        circleLayer.path = circularPath.cgPath
//        circleLayer.fillColor = UIColor.specialSixColor?.cgColor
//        backgroundCell.layer.addSublayer(circleLayer)
//    }
//}
//
//
//
//// MARK: - Constraints
//
//extension ObjectTableViewCell {
//    private func setConstraints() {
//        NSLayoutConstraint.activate([
//            backgroundCell.leadingAnchor.constraint(equalTo: leadingAnchor),
//            backgroundCell.trailingAnchor.constraint(equalTo: trailingAnchor),
//            backgroundCell.topAnchor.constraint(equalTo: topAnchor, constant: 6),
//            backgroundCell.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//            
//            labelsStackView.topAnchor.constraint(equalTo: backgroundCell.topAnchor, constant: 20),
//            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
//            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
//            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
//        
//        ])
//    }
//}
