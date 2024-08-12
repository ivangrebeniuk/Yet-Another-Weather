//
//  WeatherForecastService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation

protocol IWeatherForecastService {
    
}

final class WeatherForecastService {
    
    // Dependencies
    
    private let networkService: INetworkService
    private let urlRequestsFactory: IURLRequestFactory
    
    // MARK: - Init
    
    init(networkService: INetworkService, urlRequestsFactory: IURLRequestFactory) {
        self.networkService = networkService
        self.urlRequestsFactory = urlRequestsFactory
    }
}

// MARK: - IWeatherForecastService

extension WeatherForecastService: IWeatherForecastService {
    
}
