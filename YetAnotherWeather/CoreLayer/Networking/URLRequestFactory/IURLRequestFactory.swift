//
//  IURLRequestFactory.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 08.06.2024.
//

import Foundation

protocol IURLRequestFactory: AnyObject {
    
    /// Запрос `Current`
    func makeCurrentWeatherRequest(for location: String) throws -> URLRequest
    
    /// Запрос  `Search`
    func makeSearchRequest(for location: String) throws -> URLRequest
    
    /// Запрос `Forecast`
    func makeForecastRequest(for location: String) throws -> URLRequest
}
