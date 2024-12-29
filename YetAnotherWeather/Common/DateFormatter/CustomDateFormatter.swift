//
//  CustomDateFormatter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 17.11.2024.
//

import Foundation

protocol ICustomDateFormatter {

    func localDate(from dateString: String, mask: String, timeZone: TimeZone) -> Date?
    
    func timeString(from date: Date, mask: String) -> String
}

final class CustomDateFormatter: ICustomDateFormatter {
    
    // Properties
    private lazy var dateFormatter = DateFormatter()
    
    // MARK: - ICustomDateFormatter
    
    func localDate(from dateString: String, mask: String, timeZone: TimeZone) -> Date? {
        dateFormatter.dateFormat = mask
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    func timeString(from date: Date, mask: String) -> String {
        dateFormatter.dateFormat = mask
        return dateFormatter.string(from: date)
    }
}
