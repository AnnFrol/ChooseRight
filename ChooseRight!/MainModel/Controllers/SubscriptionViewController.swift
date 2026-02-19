//
//  SubscriptionViewController.swift
//  ChooseRight!
//
//  Subscription screen with monthly and yearly plans
//

import UIKit
import StoreKit

class SubscriptionViewController: UIViewController {
    
    private let subscriptionManager = SubscriptionManager.shared
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Unlock Unlimited Comparisons"
        label.font = .sfProTextBold33()
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "One-time purchase. Create unlimited comparison lists and make better decisions"
        label.font = .sfProTextRegular16()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let featuresStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let purchaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .sfProTextSemibold18()
        button.layer.cornerRadius = 32
        button.translatesAutoresizingMaskIntoConstraints = false
        // Устанавливаем начальный текст сразу, чтобы он был виден без задержки
        button.setTitle("Unlock Premium - $9.99", for: .normal)
        return button
    }()
    
    private let restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Restore Purchases", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .sfProTextRegular14()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "xmark")
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var premiumProduct: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Разрешаем закрытие свайпом вниз
        if #available(iOS 13.0, *) {
            isModalInPresentation = false
        }
        
        setupViews()
        setupConstraints()
        setupActions()
        updatePurchaseButtonColor()
        // Устанавливаем начальный текст кнопки сразу
        updateButtons()
        // Затем загружаем продукты и обновляем цену
        loadProducts()
    }
    
    // Handle trait changes - method is deprecated in iOS 17.0 but still functional
    @available(iOS, deprecated: 17.0, message: "Use registerForTraitChanges when stable API is available")
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updatePurchaseButtonColor()
        }
    }
    
    private func updatePurchaseButtonColor() {
        // Используем specialThree на обеих темах
        purchaseButton.backgroundColor = .specialColors.threeBlueLavender
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(featuresStackView)
        contentView.addSubview(purchaseButton)
        contentView.addSubview(restoreButton)
        
        // Кнопка закрытия добавляется последней, чтобы быть поверх всех элементов
        view.addSubview(closeButton)
        
        setupFeatures()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Убеждаемся, что кнопка закрытия всегда поверх
        view.bringSubviewToFront(closeButton)
    }
    
    private func setupFeatures() {
        let features = [
            ("✓", "Unlimited comparisons"),
            ("✓", "All premium features"),
            ("✓", "Regular updates"),
            ("✓", "Priority support")
        ]
        
        for (icon, text) in features {
            let featureView = createFeatureView(icon: icon, text: text)
            featuresStackView.addArrangedSubview(featureView)
        }
    }
    
    private func createFeatureView(icon: String, text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .sfProTextBold18()
        iconLabel.textColor = .label
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .sfProTextRegular16()
        textLabel.textColor = .label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconLabel)
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 30),
            
            textLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            textLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textLabel.heightAnchor.constraint(equalToConstant: 24),
            
            containerView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return containerView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Кнопка закрытия должна быть поверх всех элементов
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 120),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            featuresStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            featuresStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            featuresStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            
            purchaseButton.topAnchor.constraint(equalTo: featuresStackView.bottomAnchor, constant: 40),
            purchaseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            purchaseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            purchaseButton.heightAnchor.constraint(equalToConstant: 78),
            
            restoreButton.topAnchor.constraint(equalTo: purchaseButton.bottomAnchor, constant: 24),
            restoreButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            restoreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        purchaseButton.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
    }
    
    private func loadProducts() {
        Task {
            await subscriptionManager.requestProducts()
            await subscriptionManager.updatePurchasedStatus()
            
            DispatchQueue.main.async {
                self.updateButtons()
            }
        }
    }
    
    private func updateButtons() {
        let products = subscriptionManager.products
        
        // Find premium product
        if let premium = products.first {
            premiumProduct = premium
            let price = premium.displayPrice
            purchaseButton.setTitle("Unlock Premium - \(price)", for: .normal)
            purchaseButton.isEnabled = true
            purchaseButton.alpha = 1.0
        } else {
            // Fallback price - $9.99
            purchaseButton.setTitle("Unlock Premium - $9.99", for: .normal)
            purchaseButton.isEnabled = true
            purchaseButton.alpha = 1.0
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func purchaseButtonTapped() {
        // Проверяем, загружается ли продукт
        if subscriptionManager.isLoading {
            showError("Loading products, please wait...")
            return
        }
        
        guard let product = premiumProduct else {
            showError("Product not available. Please try again later.")
            // Попробуем загрузить продукты снова
            loadProducts()
            return
        }
        
        purchaseProduct(product)
    }
    
    @objc private func restoreButtonTapped() {
        restoreButton.isEnabled = false
        
        Task {
            await subscriptionManager.updatePurchasedStatus()
            
            await MainActor.run {
                if subscriptionManager.hasPurchasedPremium {
                    self.showSuccess("Purchase restored successfully!")
                    // Небольшая задержка перед закрытием
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true)
                    }
                } else {
                    self.showError("No purchase found to restore")
                }
                self.restoreButton.isEnabled = true
            }
        }
    }
    
    private func purchaseProduct(_ product: Product) {
        purchaseButton.isEnabled = false
        purchaseButton.alpha = 0.6
        
        Task {
            do {
                let transaction = try await subscriptionManager.purchase(product)
                
                if transaction != nil {
                    await MainActor.run {
                        self.showSuccess("Premium unlocked!")
                        // Небольшая задержка перед закрытием, чтобы пользователь увидел сообщение
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.dismiss(animated: true)
                        }
                    }
                } else {
                    // Пользователь отменил покупку
                    await MainActor.run {
                        self.purchaseButton.isEnabled = true
                        self.purchaseButton.alpha = 1.0
                    }
                }
            } catch {
                await MainActor.run {
                    self.showError("Purchase failed: \(error.localizedDescription)")
                    self.purchaseButton.isEnabled = true
                    self.purchaseButton.alpha = 1.0
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
