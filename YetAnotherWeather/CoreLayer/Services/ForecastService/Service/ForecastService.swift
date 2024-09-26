//
//  ForecastService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 24.09.2024.
//

import Foundation

protocol IForecastService {
    
}

final class ForecastService {
    
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

extension ForecastService: IForecastService {
    
}
