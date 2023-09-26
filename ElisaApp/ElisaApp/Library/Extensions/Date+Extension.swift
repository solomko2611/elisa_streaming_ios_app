//
//  Date+Extension.swift
//  ElisaApp
//
//  Created by Dmitriy.K on 04.03.2022.
//

import Foundation

extension Date {
    
    /// Creates a date value initialized relative to 00:00:00 UTC on 1 January 1970 by a given number of milliseconds.
    /// - Parameter timeIntervalSince1970ms: number is milliseconds
    init(timeIntervalSince1970ms: TimeInterval) {
        self.init(timeIntervalSince1970: timeIntervalSince1970ms / 1000)
    }
    
    /// Returns a string representation of a current date using given DateFormatter type
    /// - Parameter formatterType: DateFormatter type
    /// - Returns: A string representation of date.
    func string(with formatterType: DateFormatter.FormatterType) -> String {
        let formatter = DateFormatter(type: formatterType, and: self)
        return formatter.string(from: self)
    }
    
    /// Returns a number of days before current and given date
    /// - Parameter date: date for which you want to calculate the difference
    /// - Returns: A number of days
    func daysBetween(date: Date) -> Int? {
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)

        return calendar.dateComponents([.day], from: date1, to: date2).value(for: .day)
    }
}
