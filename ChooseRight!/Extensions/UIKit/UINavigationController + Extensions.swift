//
//  UINavigationController + Extensions.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 22.02.2024.
//

import Foundation
import UIKit

extension UINavigationController {
    public func pushViewController (_ viewController: UIViewController, animation: Bool, completion: @escaping () -> Void)
    {
        pushViewController(viewController, animated: animation)
        
        guard animation, let coordinator = transitionCoordinator else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
