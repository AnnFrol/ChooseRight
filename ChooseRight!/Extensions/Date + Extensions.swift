//
//  Date + Extensions.swift
//  ChooseRight!
//
//  Created by Александр Фрольцов on 09.07.2023.
//

import Foundation

extension Date {
    
    func getLocalDate() -> Date {
        let timezoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        let localDate = Calendar.current.date(byAdding: .second, value: Int(timezoneOffset), to: self) ?? Date()
        return localDate
    }
}
