//
//  ComparisonListViewController + ShakeMotion.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 30.05.2024.
//

import Foundation
import UIKit

extension ComparisonListViewController {

    override var canBecomeFirstResponder: Bool {
        true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.resignFirstResponder()
//        
//        ScreenOrientationUtility.lockOrientation(.portrait)
//    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeEvent()
        }
    }
    
    private func shakeEvent() {
        
        if self.currentSortKey == itemSortKeys().value {
            
//            self.comparisonEntity.itemsArray.forEach { $0.updateTrueValuesCount() }
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
//                    self.comparisonEntity.itemsArray.map { $0.updateTrueValuesCount() }

            
            
            //        let gener = UIImpactFeedbackGenerator(style: .medium)
            //        gener.impactOccurred()
            
            self.updateSortKey(itemSortKeys().value)
        }
    }
    
    
    
}
