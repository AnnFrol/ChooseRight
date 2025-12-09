//
//  CoreDataManager.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 05.07.2023.
//

import Foundation
import CoreData

struct EntityNames {
    let comparison = "ComparisonEntity"
    let item = "ComparisonItemEntity"
    let attribute = "ComparisonAttributeEntity"
}

public class CoreDataManager: NSObject {
    
    let entity = EntityNames()
    public static let shared = CoreDataManager()
    private override init() {}
    
    private var appDelegate: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }
    
    
    
    
}
