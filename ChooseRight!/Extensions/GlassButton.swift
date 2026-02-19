//
//  GlassButton.swift
//  ChooseRight!
//
//  Liquid Glass effect button following Apple's design guidelines
//  Reference: https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
//

import UIKit

class GlassButton: UIButton {
    
    private let blurEffectView: UIVisualEffectView
    private let vibrancyEffectView: UIVisualEffectView?
    
    /// Glass material style - follows Apple's Liquid Glass design
    var glassStyle: UIBlurEffect.Style = .systemUltraThinMaterial {
        didSet {
            updateBlurEffect()
        }
    }
    
    override init(frame: CGRect) {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        if #available(iOS 13.0, *) {
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .label)
            vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        } else {
            vibrancyEffectView = nil
        }
        
        super.init(frame: frame)
        configure()
        setupTraitChangeObservation()
    }
    
    required init?(coder: NSCoder) {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        if #available(iOS 13.0, *) {
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .label)
            vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        } else {
            vibrancyEffectView = nil
        }
        
        super.init(coder: coder)
        configure()
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
            updateBorderColor()
        }
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        // Setup blur effect view
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.isUserInteractionEnabled = false
        insertSubview(blurEffectView, at: 0)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Setup vibrancy effect for better content visibility
        if let vibrancyEffectView = vibrancyEffectView {
            vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
            vibrancyEffectView.isUserInteractionEnabled = false
            blurEffectView.contentView.addSubview(vibrancyEffectView)
            
            NSLayoutConstraint.activate([
                vibrancyEffectView.topAnchor.constraint(equalTo: blurEffectView.contentView.topAnchor),
                vibrancyEffectView.leadingAnchor.constraint(equalTo: blurEffectView.contentView.leadingAnchor),
                vibrancyEffectView.trailingAnchor.constraint(equalTo: blurEffectView.contentView.trailingAnchor),
                vibrancyEffectView.bottomAnchor.constraint(equalTo: blurEffectView.contentView.bottomAnchor)
            ])
        }
        
        // Setup button appearance - Liquid Glass style
        // Corner radius will be set in layoutSubviews to make it circular
        layer.masksToBounds = true
        
        // Subtle border for glass effect - adapts to light/dark mode
        layer.borderWidth = 0.5
        updateBorderColor()
        
        // Subtle shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.1
        
        // Image rendering is handled automatically
        
        // Observe theme changes
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateAppearance),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
        }
    }
    
    private func updateBlurEffect() {
        let newBlurEffect = UIBlurEffect(style: glassStyle)
        blurEffectView.effect = newBlurEffect
        
        if #available(iOS 13.0, *), let vibrancyEffectView = vibrancyEffectView {
            let newVibrancyEffect = UIVibrancyEffect(blurEffect: newBlurEffect, style: .label)
            vibrancyEffectView.effect = newVibrancyEffect
        }
    }
    
    private func updateBorderColor() {
        if #available(iOS 13.0, *) {
            // Adaptive color for light/dark mode
            layer.borderColor = UIColor.label.withAlphaComponent(0.1).cgColor
        } else {
            layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        }
    }
    
    @objc private func updateAppearance() {
        updateBorderColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Make button circular
        layer.cornerRadius = frame.width / 2
        // Ensure blur effect view stays behind content
        sendSubviewToBack(blurEffectView)
    }
    
    
    // Update tint color to work with glass effect
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        if let image = image {
            let templateImage = image.withRenderingMode(.alwaysTemplate)
            super.setImage(templateImage, for: state)
        } else {
            super.setImage(image, for: state)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

