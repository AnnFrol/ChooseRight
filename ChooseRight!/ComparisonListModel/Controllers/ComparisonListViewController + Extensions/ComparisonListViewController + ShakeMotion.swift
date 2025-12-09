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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeEvent()
        }
            
    }
    
    private func shakeEvent() {
        
        self.comparisonEntity.itemsArray.map { $0.updateTrueValuesCount() }
       self.updateSortKey("trueValuesCount")
        
    }
    
    
    
}
