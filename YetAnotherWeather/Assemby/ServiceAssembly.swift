//
//  ServiceAssembly.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 12.06.2024.
//

import Foundation

/// Класс, который собирает сервисы
final class ServiceAssembly {
    
    // MARK: - Private
    
    private let urlRequestsFactory = URLRequestFactory()
    private let networkService = NetworkService(session: URLSession.shared)
    
    func makeWeatherNetworkService() -> IWeatherNetworkService {
        return WeatherNetworkService(
            networkService: networkService,
            requestsFactory: urlRequestsFactory
        )
    }
}
