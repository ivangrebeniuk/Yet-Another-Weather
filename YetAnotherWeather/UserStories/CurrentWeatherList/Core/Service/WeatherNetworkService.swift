//
//  WeatherNetworkService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.06.2024.
//

import Foundation
import SwiftyJSON

protocol IWeatherNetworkService {
    
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
    
    private func makeResultsArray(from dict: [Int: CurrentWeatherModel]) -> [CurrentWeatherModel] {
        var locations = [CurrentWeatherModel]()
        
        for key in 0..<dict.count {
            guard let element = dict[key] else { return [] }
            locations.append(element)
        }
        
        return locations
    }
}

// MARK: - IWeatherNetworkService

extension WeatherNetworkService: IWeatherNetworkService {
    
    func getUnorderedCurrentWeatherItems(
        for locations: [String],
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    ) {
        var locationsWeather = [Int: CurrentWeatherModel]()
        let group = DispatchGroup()
        
        locations.enumerated().forEach { [weak self] (index, location) in
            group.enter()
            self?.networkQueue.async {
                self?.getCurrentWeather(for: location) { result in
                    switch result {
                    case .success(let currentWeather):
                        locationsWeather[index] = currentWeather
                    case .failure:
                        print("Не могу загрузить погоду для \(location)")
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            let sortedLocations = self.makeResultsArray(from: locationsWeather)
            completion(.success(sortedLocations))
        }
    }
    
    func getOrderedCurrentWeatherItems(
        for locations: [String],
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    ) {
        var locationsWeather = [CurrentWeatherModel]()
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)

        for location in locations {
            group.enter()
            networkQueue.async {
                semaphore.wait()
                self.getCurrentWeather(for: location) { result in
                    switch result {
                    case .success(let currentWeather):
                        locationsWeather.append(currentWeather)
                    case .failure:
                        print("Something went wrong")
                    }
                    semaphore.signal()
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(.success(locationsWeather))
        }
    }
}
