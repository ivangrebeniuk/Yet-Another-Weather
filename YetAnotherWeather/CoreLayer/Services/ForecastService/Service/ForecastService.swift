//
//  ForecastService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 24.09.2024.
//

import Foundation

protocol IForecastService {
    
    /// get weather forecast for location with
    /// Parameters: `locationId`
    func getWeatherForecast(
        for locationId: String,
        completion: @escaping (Result<ForecastModel, Error>) -> Void
    )
}

final class ForecastService {
    
    // Dependencies
    
    private let networkService: INetworkService
    private let urlRequestsFactory: IURLRequestFactory
    
    // MARK: - Init
    
    init(
        networkService: INetworkService,
        urlRequestsFactory: IURLRequestFactory
    ) {
        self.networkService = networkService
        self.urlRequestsFactory = urlRequestsFactory
    }
}

// MARK: - IWeatherForecastService

extension ForecastService: IForecastService {
    
    func getWeatherForecast(
        for locationId: String,
        completion: @escaping (Result<ForecastModel, Error>) -> Void
    ) {
        do {
            let request = try urlRequestsFactory.makeForecastRequest(for: locationId)
            let parser = ForecastParser()
            networkService.load(request: request, parser: parser) { (result: Result<ForecastModel, Error>) in
                switch result {
                case .success(let model):
                    completion(.success(model))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}
