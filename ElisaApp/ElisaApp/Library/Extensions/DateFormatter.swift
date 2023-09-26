//
//  DateFormatter.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation

extension DateFormatter {
    
    enum FormatterType: Hashable {
        case list
        case details
    }
    
    /// Initializes a new date formatter with given type and date
    /// - Parameters:
    ///   - type: date formatter type
    ///   - date: date for which string representation should be generated
    convenience init(type: FormatterType, and date: Date) {
        self.init()
        
        switch type {
        case .list:
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                self.dateFormat = "HH:mm"
            } else if calendar.isDateInYesterday(date) {
                self.dateFormat = "'Yesterday'"
            } else if let daysBetween = date.daysBetween(date: Date()), daysBetween < 7 {
                self.dateFormat = "EEEE"
            } else {
                self.dateFormat = "MMM d"
            }
        case .details:
            let calendar = Calendar.current
            if calendar.isDateInToday(date) {
                self.dateFormat = "HH:mm"
            } else {
                self.dateFormat = "MMM d HH:mm"
            }
        }
    }
}
