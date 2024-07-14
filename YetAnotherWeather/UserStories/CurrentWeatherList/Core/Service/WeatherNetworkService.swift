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
    
//    func getOrderedCurrentWeatherAndCancelIfError(
//        for locations: [String],
//        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
//    )
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
    
    private func sortLocations(from dict: [Int: CurrentWeatherModel]) -> [CurrentWeatherModel] {
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
            let sortedLocations = self.sortLocations(from: locationsWeather)
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
    
    // Это не работает! данные продолжают загружаться
    // Попробовать обойтись БЕЗ DispatchGroup
//    func getOrderedCurrentWeatherAndCancelIfError(
//        for locations: [String],
//        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
//    ) {
//        var locationsWeather = [CurrentWeatherModel]()
//        let group = DispatchGroup()
//        let semaphore = DispatchSemaphore(value: 1)
//        
//        // Добавляем ворк айтем
//        let resultWorkItem = DispatchWorkItem {
//            completion(.success(locationsWeather))
//        }
//        
//        for location in locations {
//            group.enter()
//            networkQueue.async {
//                semaphore.wait()
//                print("Начинаем грузить данные для \(location)")
//                self.getCurrentWeather(for: location) { result in
//                    switch result {
//                    case .success(let currentWeather):
//                        print("Заканчиваем грузить данные для \(location)")
//                        locationsWeather.append(currentWeather)
//                    case .failure:
//                        // Если ошибка - то отменяем выполнение задачи
//                        resultWorkItem.cancel()
//                        print("Something went wrong")
//                    }
//                    semaphore.signal()
//                    group.leave()
//                }
//            }
//        }
//        // Вместо комплишена передаем сюда ворк айтем с комплешеном внутри
//        group.notify(queue: .main, work: resultWorkItem)
//    }
}

