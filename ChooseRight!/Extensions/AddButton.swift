//
//  AddButton.swift
//  ChooseRight!
//

import UIKit

class AddButton: UIButton {

    private let originalIcon: UIImage = {
        UIImage(named: "AddButton") ?? UIImage(systemName: "plus") ?? UIImage()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        
        accessibilityLabel = NSLocalizedString("Create new comparison", comment: "Accessibility: add button")
        accessibilityHint = NSLocalizedString("Double tap to create a new comparison.", comment: "Accessibility: add button hint")

        let backgroundColor = UIColor.specialColors.threeBlueLavender ?? .systemBlue

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = backgroundColor
            config.baseForegroundColor = .black
            config.image = originalIcon
            config.imagePlacement = .all
            config.imagePadding = 0
            config.cornerStyle = .capsule
            self.configuration = config
        } else {
            setImage(originalIcon, for: .normal)
            self.backgroundColor = backgroundColor
            tintColor = .black
            imageView?.contentMode = .center
        }

        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Always set cornerRadius from bounds so the button stays round (avoids wrong radius when frame was zero at init).
        let radius = min(bounds.width, bounds.height) / 2
        guard radius > 0 else { return }
        layer.cornerRadius = radius
    }

    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.85
        })
    }

    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.transform = .identity
            self.alpha = 1.0
        })
    }
}
