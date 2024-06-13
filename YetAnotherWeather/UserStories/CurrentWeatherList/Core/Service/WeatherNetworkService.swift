//
//  WeatherNetworkService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.06.2024.
//

import Foundation

protocol IWeatherNetworkService {
    
    func getCurrentWeather(
        for location: String,
        completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void
    )
}

final class WeatherNetworkService: IWeatherNetworkService {
    
    // Dependencies
    let networkService: INetworkService
    let requestsFactory: IURLRequestFactory
    
    // MARK: - Init
    
    init(
        networkService: INetworkService,
        requestsFactory: URLRequestFactory
    ) {
        self.networkService = networkService
        self.requestsFactory = requestsFactory
    }
    
    // MARK: - Private
    
    
    // MARK: - IWeatherNetworkService
    
    func getCurrentWeather(
        for location: String,
        completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void
    ) {
        do {
            let request = try requestsFactory.makeCurrentWeatherRequest(for: location)
            DispatchQueue.global().async { [weak self] in
                self?.networkService.performRequest(with: request) { (result: Result<CurrentWeatherModel, Error>) in
                    switch result {
                    case .success(let model):
                        completion(.success(model))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                }
                
            }
        } catch {
            completion(.failure(error))
        }
    }
}
