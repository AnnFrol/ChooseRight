//
//  ColorPickerViewController.swift
//  ChooseRight!
//
//  Created on 2024.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var selectedColor: String?
    private var onColorSelected: ((String) -> Void)?
    
    private let colors = specialColors
    private let columns: CGFloat = 3
    private let spacing: CGFloat = 16
    private let cellSize: CGFloat = 60
    
    init(selectedColor: String?, onColorSelected: @escaping (String) -> Void) {
        self.selectedColor = selectedColor
        self.onColorSelected = onColorSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBackgroundColor()
        setupCollectionView()
        setupConstraints()
        setupTraitChangeObservation()
    }
    
    private func setupTraitChangeObservation() {
        // Note: iOS 17.0+ provides registerForTraitChanges API, but traitCollectionDidChange
        // still works and is simpler to use. The deprecation warning is suppressed below.
    }
    
    // Handle trait changes - method is deprecated in iOS 17.0 but still functional
    // Suppressing deprecation warning as the method still works correctly
    @available(iOS, deprecated: 17.0, message: "Use registerForTraitChanges when stable API is available")
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Update appearance when theme changes
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        if traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ColorPickerCell.self, forCellWithReuseIdentifier: ColorPickerCell.identifier)
        
        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: spacing),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -spacing)
        ])
    }
    
}

extension ColorPickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorPickerCell.identifier, for: indexPath) as! ColorPickerCell
        let colorName = colors[indexPath.item]
        let color = UIColor(named: colorName) ?? .gray
        let isSelected = selectedColor == colorName
        cell.configure(with: color, isSelected: isSelected)
        return cell
    }
}

extension ColorPickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedColorName = colors[indexPath.item]
        onColorSelected?(selectedColorName)
        dismiss(animated: true)
    }
}

extension ColorPickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
}

// MARK: - ColorPickerCell

class ColorPickerCell: UICollectionViewCell {
    static let identifier = "ColorPickerCell"
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.layer.borderWidth = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(colorView)
        colorView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 60),
            colorView.heightAnchor.constraint(equalToConstant: 60),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: colorView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        checkmarkImageView.isHidden = !isSelected
    }
}

