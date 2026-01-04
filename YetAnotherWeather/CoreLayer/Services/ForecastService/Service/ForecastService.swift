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
    /// returns `ForecastModel`
    func getWeatherForecast(
        for locationId: String
    ) async throws -> ForecastModel
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
    
    func getWeatherForecast(for locationId: String) async throws -> ForecastModel {
        let request = try urlRequestsFactory.makeForecastRequest(for: locationId)
        let parser = ForecastParser()
        let model = try await networkService.load(request: request, parser: parser)
        
        return model
    }
}
