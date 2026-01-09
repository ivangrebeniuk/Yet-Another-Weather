//
//  CurrentWeatherService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.06.2024.
//

import Foundation
import SwiftyJSON

protocol ICurrentWeatherService: AnyObject {
    
    func getCurrentWeather(for locationId: String) async throws -> CurrentWeatherModel
    
    func getSortedCurrentWeatherItems(for locations: [Location]) async throws -> [CurrentWeatherModel]
}

final class CurrentWeatherService {
    
    // Dependencies
    let networkService: INetworkService
    let urlRequestsFactory: IURLRequestFactory
    
    // MARK: - Init
    
    init(
        networkService: INetworkService,
        urlRequestsFactory: URLRequestFactory
    ) {
        self.networkService = networkService
        self.urlRequestsFactory = urlRequestsFactory
    }
    
    // MARK: - Private
    
    private func makeResultsArray(from dict: [Int: CurrentWeatherModel]) -> [CurrentWeatherModel] {
        var locations = [CurrentWeatherModel]()
        
        for key in 0..<dict.count {
            guard let element = dict[key] else { return [] }
            locations.append(element)
        }
        
        return locations
    }
}

// MARK: - ICurrentWeatherService

extension CurrentWeatherService: ICurrentWeatherService {
    
    func getCurrentWeather(for locationId: String) async throws -> CurrentWeatherModel {
        let request = try urlRequestsFactory.makeCurrentWeatherRequest(for: locationId)
        let parser = CurrentWeatherParser()
        return try await networkService.load(request: request, parser: parser)
    }
    
    func getSortedCurrentWeatherItems(for locations: [Location]) async throws -> [CurrentWeatherModel] {
        
        guard !locations.isEmpty else { throw URLError(.badURL) }
        
        return try await withThrowingTaskGroup(of: (Int, CurrentWeatherModel?).self) { group in
            var locationsWeather = [Int: CurrentWeatherModel]()
            
            for (index, location) in locations.enumerated() {
                group.addTask {
                    let weather = try? await self.getCurrentWeather(for: location.id)
                    return (index, weather)
                }
            }
            
            for try await (index, weather) in group {
                locationsWeather[index] = weather
            }
            
            if locationsWeather.isEmpty { throw URLError(.badServerResponse) }
            
            return makeResultsArray(from: locationsWeather)
        }
    }
}
