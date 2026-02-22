//
//  OnboardingViewController.swift
//  ChooseRight!
//
//  Welcome screens for first launch
//

import UIKit

class OnboardingViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .black.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = .sfProTextRegular16()
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Let's go!", for: .normal)
        button.titleLabel?.font = .sfProTextMedium16()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 32
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()
    
    private var pages: [(imageName: String, text: String, backgroundColor: UIColor)] {
        let darkTraitCollection = UITraitCollection(userInterfaceStyle: .dark)
        return [
            ("hello1", "Hi! This is\nChoose Right!", UIColor.specialColors.fourPinkBriliantLavender?.resolvedColor(with: darkTraitCollection) ?? .systemPink),
            ("hello2", "Not sure what the right choice is?", UIColor.specialColors.threeBlueLavender?.resolvedColor(with: darkTraitCollection) ?? .systemBlue),
            ("hello3", "We help you choose — without the stress.\nStart with 1 free comparison.", UIColor.specialColors.ninePinkPaleMagenta?.resolvedColor(with: darkTraitCollection) ?? .systemPink)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupPages()
        setConstraints()
        
    }
    
    private func setupViews() {
        view.backgroundColor = pages[0].backgroundColor
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(getStartedButton)
        
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        getStartedButton.addTarget(self, action: #selector(getStartedButtonTapped), for: .touchUpInside)
        
        skipButton.accessibilityLabel = NSLocalizedString("Skip", comment: "Accessibility: skip onboarding")
        skipButton.accessibilityHint = NSLocalizedString("Double tap to skip onboarding.", comment: "Accessibility: skip hint")
        getStartedButton.accessibilityLabel = NSLocalizedString("Let's go!", comment: "Accessibility: get started")
        getStartedButton.accessibilityHint = NSLocalizedString("Double tap to start using the app.", comment: "Accessibility: get started hint")
        pageControl.accessibilityLabel = NSLocalizedString("Onboarding pages", comment: "Accessibility: page control")
        pageControl.accessibilityHint = NSLocalizedString("Swipe to see more pages.", comment: "Accessibility: page control hint")
    }
    
    private func setupPages() {
        for (_, page) in pages.enumerated() {
            let pageView = createPageView(imageName: page.imageName, text: page.text, backgroundColor: page.backgroundColor)
            contentView.addArrangedSubview(pageView)
            
            // Set app wide equal to screen wide
            pageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
    }
    
    private func createPageView(imageName: String, text: String, backgroundColor: UIColor) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Image
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        
        // Text
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .sfProTextBold33()
        textLabel.textColor = .black
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 44),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.75),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.42)
        ])
        
        return containerView
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            getStartedButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -30),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.widthAnchor.constraint(equalToConstant: 200),
            getStartedButton.heightAnchor.constraint(equalToConstant: 78)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.delegate = self
    }
    
    @objc private func skipButtonTapped() {
        finishOnboarding()
    }
    
    @objc private func getStartedButtonTapped() {
        finishOnboarding()
    }
    
    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        let mainVC = MainViewController()
        let navController = UINavigationController(rootViewController: mainVC)
        
        if let windowScene = view.window?.windowScene {
            windowScene.windows.first?.rootViewController = navController
        }
    }
}

// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        // Обновляем цвет фона при прокрутке
        let currentPage = Int(pageIndex)
        if currentPage >= 0 && currentPage < pages.count {
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = self.pages[currentPage].backgroundColor
            }
        }
        
        // Показываем кнопку Let's go! только на последней странице
        if currentPage == pages.count - 1 {
            UIView.animate(withDuration: 0.3) {
                self.skipButton.alpha = 0
                self.getStartedButton.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.skipButton.alpha = 1
                self.getStartedButton.alpha = 0
            }
        }
    }
}

