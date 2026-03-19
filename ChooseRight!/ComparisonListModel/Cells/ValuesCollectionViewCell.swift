//
//  MainCollectionViewCell.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 11.06.2023.
//

import Foundation
import UIKit

protocol valuesCollectionViewCellDelegate: AnyObject {
    func didTapValueButton(cell: ValuesCollectionViewCell)
}

class ValuesCollectionViewCell: UICollectionViewCell {
        
    weak var delegate: valuesCollectionViewCellDelegate?
    
    static let idValuesColectionViewCell = "idValuesColectionViewCell"
    
    private lazy var valueButton: PlusMinusButton = {
        let button = PlusMinusButton(type: .system)
        button.titleLabel?.font = .sfProTextRegular20()
        return button
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .specialColors.text?.withAlphaComponent(0.55)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        valueButton.addTarget(self, action: #selector(valueButtonTapped), for: .touchUpInside)
        addSubview(valueButton)
        addSubview(commentLabel)
    }
    
    @objc private func valueButtonTapped() {
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        self.delegate?.didTapValueButton(cell: self)
    }
    
    public func updateButtonTitle(state: ComparisonValueState) {
        self.valueButton.updateTitle(state: state)
    }
    
    public func updateComment(text: String?) {
        let trimmedText = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasComment = !trimmedText.isEmpty
        commentLabel.text = trimmedText
        commentLabel.isHidden = !hasComment
        valueButton.accessibilityHint = hasComment ? NSLocalizedString("Has comment", comment: "Accessibility hint for value with comment") : nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.text = nil
        commentLabel.isHidden = true
        valueButton.accessibilityHint = nil
    }
}

extension ValuesCollectionViewCell {
    private func setConstraints() {
        NSLayoutConstraint.activate([
            
            valueButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            valueButton.widthAnchor.constraint(equalToConstant: 28),
            valueButton.heightAnchor.constraint(equalToConstant: 28),
            
            commentLabel.topAnchor.constraint(equalTo: valueButton.bottomAnchor, constant: 4),
            commentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            commentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            commentLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -6),
        ])
    }
}
