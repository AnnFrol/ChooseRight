//
//  CircleTransitionAnimator.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 17.06.2023.
//

import Foundation
import UIKit

class AddButtonTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    let presentationStartButton: UIButton
    init(presentationStartButton: UIButton) {
        self.presentationStartButton = presentationStartButton
    }
    
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let presentedViewController = transitionContext.viewController(forKey: .to),
              let presentedView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        let finalFarme = transitionContext.finalFrame(for: presentedViewController)
        let startButtonFrame = presentationStartButton.convert(presentationStartButton.bounds, to: containerView) // ???bounds?
        let startButtonCenter = CGPoint(x: startButtonFrame.midX, y: startButtonFrame.midY)
        
        let circleView = createCircleView(for: presentedView)
        
        containerView.addSubview(circleView)
        containerView.addSubview(presentedView)
        
        
        
        presentedView.center = startButtonCenter
        presentedView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        circleView.center = presentedView.center
        circleView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            presentedView.transform = CGAffineTransform(scaleX: 1, y: 1)
            presentedView.frame = finalFarme
            
            circleView.transform = CGAffineTransform(scaleX: 1, y: 1)
            circleView.center = presentedView.center
            
            circleView.backgroundColor = #colorLiteral(red: 0.7339547873, green: 0.7940633893, blue: 1, alpha: 1)
            
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
        }

    func createCircleView(for view: UIView) -> UIView {
        let d = sqrt(view.bounds.width * view.bounds.height + view.bounds.height * view.bounds.height)
        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: d, height: d))
        circleView.layer.cornerRadius = d / 2
        circleView.layer.masksToBounds = true
        circleView.alpha = 0
        return circleView
        
    }
    
}
