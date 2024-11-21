//
//  Dateformatter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 17.11.2024.
//

import Foundation

protocol ICustomDateFormatter {

    func localDate(from dateString: String) -> Date?
}

final class CustomDateFormatter: ICustomDateFormatter {
    
    private let dateFormatter = DateFormatter()
    
    func localDate(from dateString: String) -> Date? {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
}
