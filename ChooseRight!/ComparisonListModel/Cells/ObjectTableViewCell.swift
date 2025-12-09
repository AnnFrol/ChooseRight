//
//  ObjectTableViewCell.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 02.04.2023.
//

import UIKit

class RoundedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.width / 2
    }
}




protocol CellColapsable: AnyObject {
    func isShorted(viewCollapsed: Bool) -> Bool
}

//protocol CellPercentCalculation: AnyObject {
//    func valueChanged() 
//}

protocol ObjectTableViewCellProtocol: AnyObject {
    func refreshCellWhenValueChanges()
    
    func isCellCollapsedNow() -> Bool
}

class ObjectTableViewCell: UITableViewCell {
    
    private var comparisonItem: ComparisonItemEntity?
        
    var plusCount = 0
    var valuesCount = 0
    
    
    var circleViewCenterX: NSLayoutConstraint?
    var circleViewCenterXConstant = CGFloat(10)
    
    var circleViewCenterY: NSLayoutConstraint?
    var circleViewCenterYConstant = CGFloat(0)
    
    var circleHeightConstraint: NSLayoutConstraint?
    var circleWidthConstraint: NSLayoutConstraint?
    
    
    var circleTrailingConstraint: NSLayoutConstraint?
    var circleDiameter = CGFloat(140)
    
    private let colorsForCircleBG = [UIColor.specialColors.oneBlueWinterWiazrd,
                             UIColor.specialColors.twoGreenMenthol,
                             UIColor.specialColors.threeBlueLavender,
                             UIColor.specialColors.fourPinkBriliantLavender,
                             UIColor.specialColors.fiveYelowFlavescent,
                             UIColor.specialColors.sixGreenMagicMint,
                             UIColor.specialColors.sevenPinkMelon,
                             UIColor.specialColors.eightYelowCalamansi,
                             UIColor.specialColors.ninePinkPaleMagenta ]
    
//    private var randomColorForCircle: UIColor = {
//        let color = UIColor.specialColors.oneBlueWinterWiazrd ?? UIColor.white
//        return color
//    }()
    
    weak var objectTableViewCellDelegate: ObjectTableViewCellProtocol?
    
    weak var cellCollapseDelegate: CellColapsable?
    var isViewCollapsed = false
    
    static let idTableViewCell = "idTableViewCell"
    
    let backgroundCell: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .specialColors.subviewBackground
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private var labelText = String()
    private var labelTextShorted = String()
    private var actualLabelText = String()
    
    private var relevanceLabelText = String()
    private var relevanceValue = 0
    
    private let progressLabel = UILabel(percentContainerLabelText: "40%")
    private let objectLabel = UILabel(containerLabelText: "Celebrate at home")
    private var labelsStackView = UIStackView()
    
    private let progressLabelInCircle = UILabel(percentContainerLabelText: "40%")
    private let objectLabelInCircle = UILabel(containerLabelText: "Celebrate at home")
    private var labelsInCircleStackView = UIStackView()
    
    public var circleBackgroundColor = UIColor.white
    
    public let circleView: RoundedView = {
       let view = RoundedView()
//        let myColor = UIColor().specialColorRandomise()
        view.backgroundColor = UIColor(named: "sixGreenMagicMint")
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    public func valueChangedRefresh(comparisonItemEntity: ComparisonItemEntity) {
        comparisonItem = comparisonItemEntity
        labelText = comparisonItem?.unwrappedName ?? "nil"
        labelTextShorted = comparisonItem?.unwrappedName.getFirstSymbols() ?? "nil"
        
        relevanceValue = comparisonItem?.getRelevance ?? 0
        
        relevanceLabelText = "\(String(relevanceValue))%"
        progressLabel.text = relevanceLabelText
        progressLabelInCircle.text = relevanceLabelText
        
        UIView.animate(withDuration: 0.3) { [self] in
            self.circleDiameter = self.calculateCircleDiameter(relevanceValue: self.relevanceValue)
            self.layoutIfNeeded()
        }
        
        print("relevanceValue = \(relevanceLabelText), sizeMultiplier = \(circleDiameter)")
    }
    
    public func configureCell(comparisonItemEntity: ComparisonItemEntity) {
        
        comparisonItem = comparisonItemEntity
        labelText = comparisonItem?.unwrappedName ?? "nil"
        labelTextShorted = comparisonItem?.unwrappedName.getFirstSymbols() ?? "nil"
        
        relevanceValue = comparisonItem?.getRelevance ?? 0
        relevanceLabelText = "\(String(relevanceValue))%"
      
        actualLabelText = isViewCollapsed ? labelTextShorted : labelText

        objectLabel.text = actualLabelText
        objectLabelInCircle.text = actualLabelText
        
        progressLabel.text = relevanceLabelText
        progressLabelInCircle.text = relevanceLabelText
        
        
        print("Label text: \(labelText), shorted: \(labelTextShorted)")
        
        circleBackgroundColor = UIColor(named: comparisonItem?.color ?? "sixGreenMagicMint") ?? UIColor.white
        circleView.backgroundColor = circleBackgroundColor

    }
    
    public func refreshCell() {
        
        labelText = comparisonItem?.unwrappedName ?? "nil"
        labelTextShorted = comparisonItem?.unwrappedName.getFirstSymbols() ?? "nil"
        
        relevanceValue = comparisonItem?.getRelevance ?? 0
        relevanceLabelText = "\(String(relevanceValue))%"
      
        actualLabelText = isViewCollapsed ? labelTextShorted : labelText

        objectLabel.text = actualLabelText
        objectLabelInCircle.text = actualLabelText
        
        progressLabel.text = relevanceLabelText
        progressLabelInCircle.text = relevanceLabelText
        
        
        print("Label text: \(labelText), shorted: \(labelTextShorted)")
        
        circleBackgroundColor = UIColor(named: comparisonItem?.color ?? "sixGreenMagicMint") ?? UIColor.white
        circleView.backgroundColor = circleBackgroundColor
    }
    
    private func calculateCircleDiameter(relevanceValue: Int) -> Double {
        
        var multiplier = 0.0
        switch isViewCollapsed {
        case true:
            if relevanceValue == 100 {
                multiplier = 1.24 }
            else { multiplier = 0.8 }
        case false:
            if relevanceValue == 100 {
                multiplier = 1.68 }
            else { multiplier = 1.5 }
        }
        
        print("isViewCollapsed = \(isViewCollapsed)")
        
        let relevance = Double(relevanceValue)
        
                    let minUIRelevance: CGFloat = 28
        let maxUIRelevance = max(self.frame.width, self.frame.height)
                    let calculatedSize = minUIRelevance + (relevance / 100) * (maxUIRelevance * multiplier + minUIRelevance)
        
        
        print("viewSize = \(self.frame), item = \(comparisonItem?.unwrappedName ?? "nil"), maxUIRelevance = \(maxUIRelevance), minUIRelevance = \(minUIRelevance), calculatedSize = \(calculatedSize) ")
        return calculatedSize
    }
    
    
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setConstraints()
                
    }
    
    private func isCellCollapsed() -> Bool {
        
        guard let delegateReport = objectTableViewCellDelegate?.isCellCollapsedNow() else { return false }
        
        
        print("CONTROLLER REPORTS THAT CELL COLLAPSED IS \(delegateReport)")
//        let currentWidth = self.frame.width
//        switch currentWidth {
//        case ..<230:
//            return true
//        default:
//            return false
//        }
        return delegateReport
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        circleDiameter =  sizeMultiplier //* frame.width

        

        
        
        UIView.animate(withDuration: 0.3) { [self] in
            
            self.isViewCollapsed = isCellCollapsed()

            self.circleDiameter = self.calculateCircleDiameter(relevanceValue: self.relevanceValue)
            self.actualLabelText = isViewCollapsed ? labelTextShorted : labelText
            self.objectLabel.text = actualLabelText
            self.objectLabelInCircle.text = actualLabelText
            self.layoutIfNeeded()
        }
        
        
        circleWidthConstraint?.constant =  circleDiameter//(circleRadius - 24) * 2
        circleHeightConstraint?.constant = circleDiameter//(circleRadius - 24) * 2
        
//        objectTableViewCellDelegate?.refreshCellWhenValueChanges()

//        print("circle height: \(circleView.frame.size.height), circle width \(circleView.frame.size.width)")
//        print("cornerRadius: ",circleView.layer.cornerRadius)
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        //        translatesAutoresizingMaskIntoConstraints = false
        
        layer.cornerRadius = 10
        backgroundColor = .clear
        selectionStyle = .none
        isUserInteractionEnabled = true
        
        addSubview(backgroundCell)
        
        labelsStackView = UIStackView(arrangedSubviews: [progressLabel,
                                                        objectLabel],
                                      axis: .vertical,
                                      spacing: 0)
        labelsStackView.distribution = .equalSpacing
//        addSubview(labelsStackView)
        isUserInteractionEnabled = true
        backgroundCell.addSubview(labelsStackView)
        
        
        progressLabelInCircle.textColor = .black
        objectLabelInCircle.textColor = .black
        labelsInCircleStackView = UIStackView(arrangedSubviews: [progressLabelInCircle,
                                                                 objectLabelInCircle],
                                              axis: .vertical,
                                              spacing: 0)
        labelsInCircleStackView.distribution = .equalSpacing
        
        circleView.addSubview(labelsInCircleStackView)
        backgroundCell.addSubview(circleView)
        
    }
    
}


// MARK: - Constraints

extension ObjectTableViewCell {
    private func setConstraints() {
        
        circleWidthConstraint =  circleView.widthAnchor.constraint(equalToConstant: (frame.width * 0.4 - 24) * 2)
        circleHeightConstraint = circleView.heightAnchor.constraint(equalToConstant: (frame.width * 0.4 - 24) * 2)
        
        circleViewCenterX = circleView.centerXAnchor.constraint(equalTo: labelsInCircleStackView.arrangedSubviews[0].leadingAnchor, constant: circleViewCenterXConstant)
        circleViewCenterY = circleView.centerYAnchor.constraint(equalTo: labelsInCircleStackView.arrangedSubviews[0].centerYAnchor, constant: circleViewCenterYConstant)


        
        NSLayoutConstraint.activate([
            backgroundCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundCell.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundCell.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            backgroundCell.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            
            labelsStackView.topAnchor.constraint(equalTo: backgroundCell.topAnchor, constant: 20),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
                        
            labelsInCircleStackView.topAnchor.constraint(equalTo: labelsStackView.topAnchor),
            labelsInCircleStackView.leadingAnchor.constraint(equalTo: labelsStackView.leadingAnchor),
            labelsInCircleStackView.bottomAnchor.constraint(equalTo: labelsStackView.bottomAnchor),
            labelsInCircleStackView.trailingAnchor.constraint(equalTo: labelsStackView.trailingAnchor),
            
            circleViewCenterX ?? circleView.centerXAnchor.constraint(equalTo: labelsInCircleStackView.arrangedSubviews[0].leadingAnchor, constant: 10),
            circleViewCenterY ?? circleView.centerYAnchor.constraint(equalTo: labelsInCircleStackView.arrangedSubviews[0].centerYAnchor, constant: 0),

            circleWidthConstraint ?? circleView.widthAnchor.constraint(equalToConstant: (frame.width * 0.4 - 24) * 2),
            circleHeightConstraint ?? circleView.heightAnchor.constraint(equalToConstant: (frame.width * 0.4 - 24) * 2),
            

            
            
            

        ])
        print("Circle radius in setConstraints func finish: ", circleDiameter)

    }
}

