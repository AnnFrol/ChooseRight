//
//  UIViewController + Extensions.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 17.06.2023.
//

import Foundation
import UIKit

public enum DetailsClosingType {
    case button
    case swipe
}

protocol DraggableViewControllerProtocol: AnyObject {
    func willDismissView()
}

extension UIViewController {
    
    

    //Two helper functions for dissmissing by dragging
    func ProgressAlongAxis(_ pointOnAxis: CGFloat,
                           _ axisLength: CGFloat) -> CGFloat {

        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)

        return CGFloat(positiveMovementOnAxisPercent)
    }

    func ensureRange<T>(value :T,
                        minimum: T,
                        maximum: T) -> T where T: Comparable {

        return min(max(value, minimum), maximum)
    }
}

extension UIViewController {
    func showToast(message: String, icon: UIImage? = nil, duration: TimeInterval = 1.0) {
        let toastView = UIView(frame: CGRect())
        toastView.backgroundColor = UIColor.specialColors.text?.withAlphaComponent(0.1)
        toastView.alpha = 0
        toastView.layer.cornerRadius = 10
        toastView.clipsToBounds = true
        
        let imageView = UIImageView(image: icon)
        imageView.tintColor = UIColor.specialColors.text?.withAlphaComponent(0.3)
        imageView.contentMode = .scaleAspectFit
        
        imageView.alpha = 0.2
        
        let textLabel = UILabel(frame: CGRect())
        textLabel.textColor = UIColor.specialColors.text?.withAlphaComponent(0.3)
        textLabel.textAlignment = .center
        textLabel.font = .sfProTextRegular14()
        textLabel.text = message
        textLabel.clipsToBounds = true
        textLabel.numberOfLines = 0
        
        let stackView = UIStackView(
            arrangedSubviews: [imageView, textLabel],
            axis: .horizontal,
            spacing: 8)
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        toastView.addSubview(stackView)
        self.view.addSubview(toastView)
        
        stackView.centerXAnchor.constraint(equalTo: toastView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: toastView.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -8).isActive = true
        stackView.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 8).isActive = true
        stackView.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -8).isActive = true
        
        toastView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toastView)
        
        let centerX = toastView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let bottom = toastView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80)
        let width = toastView.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        
        NSLayoutConstraint.activate([centerX, bottom, width])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseIn, animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
        
        
    }
    
    func showImportSuccessAlert() {
        // Create container view (Dark background)
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        containerView.layer.cornerRadius = 20
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.alpha = 0
        
        // Background dimming
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.alpha = 0
        
        // --- Content ---
        
        // Checkmark Icon
        let checkmarkImage = UIImage(systemName: "checkmark.circle")
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 52, weight: .light)
        let checkmarkImageView = UIImageView(image: checkmarkImage?.withConfiguration(imageConfig))
        checkmarkImageView.tintColor = .white
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Comparison imported", comment: "")
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Message Label
        let messageLabel = UILabel()
        messageLabel.text = NSLocalizedString("The comparison has been successfully added to your list.", comment: "")
        messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        messageLabel.textColor = .lightGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // OK Button
        let okButton = UIButton(type: .system)
        okButton.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        okButton.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        okButton.layer.cornerRadius = 22 // Pill shape
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.addAction(UIAction { [weak self] _ in
            self?.dismissImportSuccessAlert()
        }, for: .touchUpInside)
        
        // Add subviews
        containerView.addSubview(checkmarkImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(okButton)
        
        // Add to main view
        if let window = view.window {
            window.addSubview(dimmingView)
            window.addSubview(containerView)
            
            // Store for dismissal
            objc_setAssociatedObject(self, &AssociatedKeys.importSuccessBlurView, dimmingView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &AssociatedKeys.importSuccessContainerView, containerView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Constraints
            NSLayoutConstraint.activate([
                // Dimming view covers whole screen
                dimmingView.topAnchor.constraint(equalTo: window.topAnchor),
                dimmingView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                dimmingView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                dimmingView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                
                // Container View
                containerView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                containerView.widthAnchor.constraint(equalToConstant: 290), // Fixed width like standard alert
                // Height will be determined by content
                
                // Icon
                checkmarkImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
                checkmarkImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                
                // Title
                titleLabel.topAnchor.constraint(equalTo: checkmarkImageView.bottomAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                
                // Message
                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                
                // Button
                okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
                okButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
                okButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
                okButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
                okButton.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            // Animate In
            containerView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                dimmingView.alpha = 1
                containerView.alpha = 1
                containerView.transform = .identity
            }
        }
    }
    
    private func dismissImportSuccessAlert() {
        guard let dimmingView = objc_getAssociatedObject(self, &AssociatedKeys.importSuccessBlurView) as? UIView,
              let containerView = objc_getAssociatedObject(self, &AssociatedKeys.importSuccessContainerView) as? UIView else {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            dimmingView.alpha = 0
            containerView.alpha = 0
            containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            dimmingView.removeFromSuperview()
            containerView.removeFromSuperview()
        }
    }
}

// Associated object keys
private struct AssociatedKeys {
    static var importSuccessBlurView: UInt8 = 0
    static var importSuccessContainerView: UInt8 = 0
}





// MARK: - DraggableViewController

public class DraggableViewController: UIViewController {
    
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterial)

    var blurView = UIVisualEffectView()

    
    var draggableViewControllerDelegate: DraggableViewControllerProtocol?
    
    func startClosingAnimation(type: DetailsClosingType) {
        if type == .button {
            addBlurView()
        }

        UIView.animate(withDuration: 0.2, animations: {
            
            self.draggableViewControllerDelegate?.willDismissView() //reloadDataOnPresentingVC
            
            switch self.axis {
            case .vertical:
                self.view.frame.origin.y = self.view.bounds.height

            case .horizontal:
                self.view.frame.origin.x = self.view.bounds.width
            @unknown default:
                break
            }
            
            UIView.animate(withDuration: 0.4) {
                self.blurView.alpha = 0
            }

        }, completion: { finish in
            self.dismiss(animated: false) {
            }
//                {
//                    if let myPresenter = self.presentingViewController as? ComparisonListViewController {
//                        myPresenter.reloadTables()
//                    }
//                }
        })
    }

    public let percentThresholdDismiss: CGFloat = 0.3
    public var velocityDismiss: CGFloat = 300
    public var axis: NSLayoutConstraint.Axis = .vertical
    public var backgroundDismissColor: UIColor = .specialColors.background ?? .white {
        didSet {
            navigationController?.view.backgroundColor = backgroundDismissColor
        }
    }

    // MARK: LifeCycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        addBlurView()

        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:))))
    }
    


    // MARK: Private methods

    private func addBlurView() {
        blurView.effect = blurEffect
        self.presentationController?.containerView?.insertSubview(blurView, belowSubview: self.view)
//        blurView.alpha =
        blurView.frame = self.presentationController?.containerView?.bounds ?? CGRect(x: 0, y: 0, width: 100, height: 100)
    }
    @objc fileprivate func onDrag(_ sender: UIPanGestureRecognizer) {
        
        addBlurView()

        let translation = sender.translation(in: view)

        // Movement indication index
        var movementOnAxis: CGFloat = 0.0

        // Move view to new position
        switch axis {
        case .vertical:
            let newY = min(max(view.frame.minY + translation.y, 0), view.frame.maxY)
            movementOnAxis = newY / view.bounds.height
            view.frame.origin.y = newY

        case .horizontal:
            let newX = min(max(view.frame.minX + translation.x, 0), view.frame.maxX)
            movementOnAxis = newX / view.bounds.width
            view.frame.origin.x = newX
//            let height = view.frame.size.height - movementOnAxis
//            view.frame.size.height = height
        @unknown default:
            break
        }
        
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
        let progress = CGFloat(positiveMovementOnAxisPercent)
//        navigationController?.view.backgroundColor = .specialColors.background//UIColor.black.withAlphaComponent(1 - progress)
        
        switch sender.state {
        case .ended where sender.velocity(in: view).y >= velocityDismiss || progress > percentThresholdDismiss:
            // After animate, user made the conditions to leave
            startClosingAnimation(type: .swipe)
//            UIView.animate(withDuration: 0.2, animations: {
//                
//                self.draggableViewControllerDelegate?.willDismissView() //reloadDataOnPresentingVC
//                
//                switch self.axis {
//                case .vertical:
//                    self.view.frame.origin.y = self.view.bounds.height
//
//                case .horizontal:
//                    self.view.frame.origin.x = self.view.bounds.width
//                @unknown default:
//                    fatalError("axis error")
//                }
//                
//                UIView.animate(withDuration: 0.3) {
//                    self.blurView.alpha = 0
//                }
////                self.navigationController?.view.backgroundColor = .specialColors.background//UIColor.black.withAlphaComponent(0)
//
//            }, completion: { finish in
////                self.dismiss(animated: true)
////                self.dismiss(animated: true, completion: self.presentationController?.containerView?.removeFromSuperview)//Perform dismiss
//                
////                self.animateTra
////                if let myPresenter = self.presentingViewController {
////                    myPresenter.dismiss(animated: true, completion: nil)
////                }
////                if let presented = self.presentedViewController {
////                    self.navigationController?.setNavigationBarHidden(true, animated: false)
////                    presented.dismiss(animated: true, completion: nil)
////                }
////                self.navigationController?.popToRootViewController(animated: true)
////                self.presentationController?.containerView?.backgroundColor = .lightGray
//                
//
//                self.dismiss(animated: false) {
//                }
////                {
////                    if let myPresenter = self.presentingViewController as? ComparisonListViewController {
////                        myPresenter.reloadTables()
////                    }
////                }
//            })
        case .ended:
            // Revert animation
            UIView.animate(withDuration: 0.2, animations: {
                switch self.axis {
                case .vertical:
                    self.view.frame.origin.y = 0

                case .horizontal:
                    self.view.frame.origin.x = 0
                @unknown default:
                    break
                }
            })
        default:
            break
        }
        sender.setTranslation(.zero, in: view)
    }
}
