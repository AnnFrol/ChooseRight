//
//  CircleTransitionAnimator.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 17.06.2023.
//

import Foundation
import UIKit

class AddButtonTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
        
    let presentationViewController: UIViewController.Type
    
    let isPresenting: Bool
    
    init(presentationViewController: UIViewController.Type, isPresenting: Bool) {
        self.presentationViewController = presentationViewController
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            present(using: transitionContext)
        } else {
            dismiss(using: transitionContext)
        }
        

    }
    
    func present(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let presentedViewController = transitionContext.viewController(forKey: .to),
              let presentedView = transitionContext.view(forKey: .to)
              
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let finalFarme = transitionContext.finalFrame(for: presentedViewController)
        
        let bluredView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        bluredView.frame = containerView.frame
        bluredView.alpha = 0.1
        
        containerView.addSubview(bluredView)
        containerView.addSubview(presentedView)
        
        presentedView.center = CGPoint(x: containerView.frame.midX, y: containerView.frame.height * 1.5)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            
            presentedView.transform = CGAffineTransform(scaleX: 1, y: 1)
            presentedView.frame = finalFarme
            
            bluredView.alpha = 1
            
        } completion: { finished in
            bluredView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
    
    func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let dismissedView = transitionContext.view(forKey: .from),
              let presentedView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        

        
        let bluredView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        bluredView.frame = containerView.frame
        bluredView.alpha = 1
        
        
//        containerView.addSubview(bluredView)
        containerView.insertSubview(bluredView, belowSubview: dismissedView)
        containerView.insertSubview(presentedView, belowSubview: bluredView)
        
        
        UIView.animate(withDuration: 0.3) {
            
            dismissedView.center = CGPoint(x: containerView.frame.midX, y: containerView.frame.height * 1.5)
            
            bluredView.alpha = 0
            
        } completion: { finished in
            bluredView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
//    func createCircleView(for view: UIView) -> UIView {
//        let d = sqrt(view.bounds.width * view.bounds.height + view.bounds.height * view.bounds.height)
//        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: d, height: d))
//        circleView.layer.cornerRadius = d / 2
//        circleView.layer.masksToBounds = true
//        circleView.alpha = 1
//        return circleView
//
//    }
    
}
