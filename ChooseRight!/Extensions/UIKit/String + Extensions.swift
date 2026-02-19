//
//  String + Extensions.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 27.10.2023.
//

import Foundation

extension String {
    
    func getFirstSymbols() -> String {
        let name = self
        let nameSplited = self.split(separator: " ")
        let spacer = " "
        
        if nameSplited.count > 1 {
            return nameSplited.reduce("", {$0 + String($1[$1.startIndex]) + spacer}).uppercased()
        }
        return name
    }
    
    func containsCharacters() -> Bool {
        
        let string = self
        let result = string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return !result
    }
}
