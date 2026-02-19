//
//  AddButton.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 04.04.2023.
//

import UIKit

class AddButton: UIButton {
    
    var imageHeight = NSLayoutConstraint()
    var imageWidth = NSLayoutConstraint()
    
    // Используем оригинальную иконку из Assets
    private let originalIcon: UIImage = {
        return UIImage(named: "addButton") ?? UIImage()
    }()
    
    private var blurEffectView: UIVisualEffectView?
    private var glassLayer: CALayer?
    private var colorLayer: CALayer?
    
    // Цвет для Liquid Glass фона (можно настроить)
    var glassColor: UIColor? {
        didSet {
            updateColorLayer()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = false
        
        // Используем системный акцентный цвет для Liquid Glass
        // Это цвет, который используется в приложении по умолчанию
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            glassColor = window.tintColor ?? .systemBlue
        } else {
            glassColor = .systemBlue
        }
        
        // Используем UIButton.Configuration для стиля glassProminent (iOS 15+)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .clear
            // Используем оригинальный цвет для иконки (не белый)
            config.baseForegroundColor = glassColor ?? .systemBlue
            // Используем оригинальную иконку
            config.image = originalIcon
            config.imagePlacement = .all
            config.imagePadding = 0
            config.cornerStyle = .capsule
            
            // Настройка background с glass эффектом (glassProminent style)
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.visualEffect = UIBlurEffect(style: .systemMaterial)
            if let glassColor = glassColor {
                // Используем оригинальный цвет для фона Liquid Glass
                backgroundConfig.backgroundColor = glassColor.withAlphaComponent(0.7)
            }
            // Добавляем тонкую обводку
            backgroundConfig.strokeColor = UIColor.label.withAlphaComponent(0.2)
            backgroundConfig.strokeWidth = 0.5
            config.background = backgroundConfig
            
            self.configuration = config
            self.configurationUpdateHandler = { button in
                // Обновляем конфигурацию при изменении состояния
                var updatedConfig = button.configuration ?? config
                if let glassColor = self.glassColor {
                    // background не опциональный, используем прямое обращение
                    updatedConfig.background.backgroundColor = glassColor.withAlphaComponent(0.7)
                    // Обновляем цвет иконки
                    updatedConfig.baseForegroundColor = glassColor
                }
                button.configuration = updatedConfig
            }
        } else {
            // Fallback для iOS 14 и ниже
            setupLiquidGlassEffect()
            // Используем оригинальную иконку
            setImage(originalIcon, for: .normal)
            // Используем оригинальный цвет для иконки
            tintColor = glassColor ?? .systemBlue
            imageView?.contentMode = .center
            bringSubviewToFront(imageView ?? UIView())
        }
        
        // Добавляем обработчики для интерактивности
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    private func setupLiquidGlassEffect() {
        // Создаем цветной слой под blur для эффекта цветного стекла
        let colorLayer = CALayer()
        colorLayer.frame = bounds
        colorLayer.cornerRadius = bounds.height / 2
        layer.insertSublayer(colorLayer, at: 0)
        self.colorLayer = colorLayer
        
        // Обновляем цвет слоя
        updateColorLayer()
        
        // Создаем blur effect с tinted material для цветного эффекта
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.isUserInteractionEnabled = false
        blurEffectView.alpha = 0.7 // Немного уменьшаем прозрачность blur для большей видимости цвета
        
        // Добавляем blur view как subview поверх цветного слоя
        insertSubview(blurEffectView, at: 1)
        self.blurEffectView = blurEffectView
        
        // Constraints для blur view
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Настройка слоя для эффекта стекла
        layer.cornerRadius = 32 // Половина размера кнопки (64/2)
        layer.masksToBounds = true
        
        // Тонкая обводка в стиле Liquid Glass
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.label.withAlphaComponent(0.2).cgColor
        
        // Мягкая тень для глубины
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.15
        
        // Добавляем градиентный слой для дополнительного эффекта стекла
        // Уменьшаем белый градиент, чтобы цвет был более заметен
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.white.withAlphaComponent(0.15).cgColor,
            UIColor.white.withAlphaComponent(0.05).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 32
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 1)
        self.glassLayer = gradientLayer
    }
    
    private func updateColorLayer() {
        guard let colorLayer = colorLayer, let glassColor = glassColor else { return }
        
        // Используем более насыщенный цвет для эффекта цветного стекла
        // Увеличиваем alpha для большей насыщенности
        colorLayer.backgroundColor = glassColor.withAlphaComponent(0.65).cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Обновляем размеры всех слоев при изменении bounds
        colorLayer?.frame = bounds
        colorLayer?.cornerRadius = bounds.height / 2
        
        glassLayer?.frame = bounds
        glassLayer?.cornerRadius = bounds.height / 2
        
        layer.cornerRadius = bounds.height / 2
        
        // Убеждаемся, что иконка всегда поверх всех слоев
        bringSubviewToFront(imageView ?? UIView())
    }
    
    @objc private func buttonPressed() {
        // Анимация при нажатии
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.8
        })
    }
    
    @objc private func buttonReleased() {
        // Анимация при отпускании
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.transform = .identity
            self.alpha = 1.0
        })
    }
}

