//
//  CustomDateFormatter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 17.11.2024.
//

import Foundation

protocol ICustomDateFormatter {

    func localDate(from dateString: String, mask: String, timeZone: TimeZone) -> Date?
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
}
