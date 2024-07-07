//
//  WeatherNetworkService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.06.2024.
//

import Foundation
import SwiftyJSON

protocol IWeatherNetworkService {
    
    func getSearchResults(
        for location: String,
        completion: @escaping (Result<[SearchResult], Error>) -> Void
    )
    
    func searchAndGetCurrentWeather(
        for location: String,
        completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void
    )
    
    func getUnorderedCurrentWeatherItems(
        for locations: [String],
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    ) 
    
    func getOrderedCurrentWeatherItems(
        for locations: [String],
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    )
}

final class WeatherNetworkService {
    
    // Dependencies
    let networkQueue: DispatchQueue
    let networkService: INetworkService
    let requestsFactory: IURLRequestFactory
    
    // MARK: - Init
    
    init(
        networkQueue: DispatchQueue,
        networkService: INetworkService,
        requestsFactory: URLRequestFactory
    ) {
        self.networkQueue = networkQueue
        self.networkService = networkService
        self.requestsFactory = requestsFactory
    }
    
    // MARK: - Private
    
    private func getCurrentWeather(
        for location: String,
        completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void
    ) {
        do {
            let request = try requestsFactory.makeCurrentWeatherRequest(for: location)
            self.networkService.load(request: request, parser: CurrentWeatherParser()) { (result: Result<CurrentWeatherModel, Error>) in
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

// MARK: - IWeatherNetworkService

extension WeatherNetworkService: IWeatherNetworkService {
    
    func getSearchResults(
        for location: String,
        completion: @escaping (Result<[SearchResult], Error>) -> Void
    ) {
        do {
            let request = try requestsFactory.makeSearchRequest(for: location)
                self.networkService.loadModels(
                    request: request
                ) { (result: Result<([SearchResult]), Error>) in
                switch result {
                case.success(let models):
                    completion(.success(models))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func searchAndGetCurrentWeather(
        for location: String,
        completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void
    ) {
        getSearchResults(for: location) { [weak self] result in
            switch result {
            case .success(let searchResults):
                guard !searchResults.isEmpty else { return }
                let city = searchResults[0].name
                print("Запрашиваем погоду для города, который искали: \(city)")
                self?.getCurrentWeather(for: city) { result in
                    switch result {
                    case .success(let result):
                        completion(.success(result))
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func getUnorderedCurrentWeatherItems(
        for locations: [String],
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    ) {
        var locationsWeather = [CurrentWeatherModel]()
        let group = DispatchGroup()
        
        locations.forEach { [weak self] location in
            group.enter()
            self?.networkQueue.async {
                self?.getCurrentWeather(for: location) { result in
                    switch result {
                    case .success(let currentWeather):
                        locationsWeather.append(currentWeather)
                    case .failure:
                        print("Something went wrong")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(.success(locationsWeather))
            }
        }
    }
    
    func getOrderedCurrentWeatherItems(
        for locations: [String],
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    ) {
        var locationsWeather = [CurrentWeatherModel]()
        let group = DispatchGroup()
        let semapthore = DispatchSemaphore(value: 1)

        for location in locations {
            group.enter()
            networkQueue.async {
                semapthore.wait()
                self.getCurrentWeather(for: location) { result in
                    switch result {
                    case .success(let currentWeather):
                        locationsWeather.append(currentWeather)
                    case .failure:
                        print("Something went wrong")
                    }
                    semapthore.signal()
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(.success(locationsWeather))
        }
    }
}

