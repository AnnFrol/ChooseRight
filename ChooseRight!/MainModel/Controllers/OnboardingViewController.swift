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
        pageControl.pageIndicatorTintColor = .specialColors.detailsOptionTableText?.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .specialColors.text
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = .sfProTextRegular16()
        button.setTitleColor(.specialColors.detailsOptionTableText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.titleLabel?.font = .sfProTextMedium16()
        button.setTitleColor(.specialColors.text, for: .normal)
        button.backgroundColor = .specialColors.oneBlueWinterWiazrd
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        return button
    }()
    
    private var pages: [(imageName: String, text: String, backgroundColor: UIColor)] {
        let darkTraitCollection = UITraitCollection(userInterfaceStyle: .dark)
        return [
            ("hello1", "Hello, this is the Choice Right!", UIColor.specialColors.fourPinkBriliantLavender?.resolvedColor(with: darkTraitCollection) ?? .systemPink),
            ("hello2", "Don't know how to make a choice and not make a mistake?", UIColor.specialColors.threeBlueLavender?.resolvedColor(with: darkTraitCollection) ?? .systemBlue),
            ("hello3", "We will save you from the torment of choice!", UIColor.specialColors.ninePinkPaleMagenta?.resolvedColor(with: darkTraitCollection) ?? .systemPink)
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupPages()
        setConstraints()
        
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
    }
    
    private func setupViews() {
        view.backgroundColor = pages[0].backgroundColor
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(getStartedButton)
        
        getStartedButton.addTarget(self, action: #selector(getStartedButtonTapped), for: .touchUpInside)
    }
    
    private func setupPages() {
        for (_, page) in pages.enumerated() {
            let pageView = createPageView(imageName: page.imageName, text: page.text, backgroundColor: page.backgroundColor)
            contentView.addArrangedSubview(pageView)
            
            // Устанавливаем ширину каждой страницы равной ширине экрана
            pageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
    }
    
    private func createPageView(imageName: String, text: String, backgroundColor: UIColor) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = backgroundColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Navigation bar (notchView style)
        let navBarLabel = UILabel()
        navBarLabel.text = "    Choose Right!    "
        navBarLabel.font = .sfProDisplaySemibold12()
        navBarLabel.backgroundColor = .specialColors.threeBlueLavender
        navBarLabel.textColor = .specialColors.detailsMainLabelText
        navBarLabel.translatesAutoresizingMaskIntoConstraints = false
        navBarLabel.layer.cornerRadius = 20
        navBarLabel.clipsToBounds = true
        containerView.addSubview(navBarLabel)
        
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
        textLabel.textColor = .specialColors.background
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            navBarLabel.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 10),
            navBarLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.4),
            
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            textLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
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
            
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.widthAnchor.constraint(equalToConstant: 200),
            getStartedButton.heightAnchor.constraint(equalToConstant: 50),
            
            pageControl.bottomAnchor.constraint(equalTo: getStartedButton.topAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        
        // Показываем кнопку Get Started на последней странице
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

