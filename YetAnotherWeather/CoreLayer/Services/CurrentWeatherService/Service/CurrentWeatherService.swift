//
//  CurrentWeatherService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 01.06.2024.
//

import Foundation
import SwiftyJSON

private extension String {
    static let userDefaultsKey = "FavouriteLocations"
}

protocol ICurrentWeatherService {
    
    var cachedFavourites: [String] { get }
        
    func saveToFavourites(_ location: String)
    
    func deleteFromFavourites(_ index: Int)
    
    func getCurrentWeather(
        for location: String,
        completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void
    )
    
    func getSortedCurrentWeatherItems(
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    )
    
    func getOrderedCurrentWeatherItems(
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    )
}

final class CurrentWeatherService {
    
    // Dependencies
    let dataBaseQueue: DispatchQueue
    let networkQueue: DispatchQueue
    let networkService: INetworkService
    let urlRequestsFactory: IURLRequestFactory
    let userDefaults: UserDefaults
    
    // MARK: - Init
    
    init(
        dataBaseQueue: DispatchQueue,
        networkQueue: DispatchQueue,
        networkService: INetworkService,
        urlRequestsFactory: URLRequestFactory,
        userDefaults: UserDefaults
    ) {
        self.dataBaseQueue = dataBaseQueue
        self.networkQueue = networkQueue
        self.networkService = networkService
        self.urlRequestsFactory = urlRequestsFactory
        self.userDefaults = userDefaults
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
    
    // MARK: - Private
    
    private func updateFavourites(_ favourites: [String]) {
        dataBaseQueue.async { [weak self] in
            self?.userDefaults.set(favourites, forKey: .userDefaultsKey)
        }
    }
}

// MARK: - ICurrentWeatherService

extension CurrentWeatherService: ICurrentWeatherService {
    
    var cachedFavourites: [String] {
        dataBaseQueue.sync {
            return userDefaults.array(forKey: .userDefaultsKey) as? [String] ?? []
        }
    }

    func saveToFavourites(_ location: String) {
        var cached = cachedFavourites
        guard !cached.contains(location) else { return }
    
        cached.append(location)
        updateFavourites(cached)
    }
    
    func deleteFromFavourites(_ index: Int) {
        var cached = cachedFavourites
        guard index < cached.count else { return }
        cached.remove(at: index)
        updateFavourites(cached)
    }
    
    func getCurrentWeather(
        for location: String,
        completion: @escaping (Result<CurrentWeatherModel, Error>) -> Void
    ) {
        do {
            let request = try urlRequestsFactory.makeCurrentWeatherRequest(for: location)
            let parser = CurrentWeatherParser()
            networkService.load(request: request, parser: parser) { (result: Result<CurrentWeatherModel, Error>) in
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
    
    func getSortedCurrentWeatherItems(
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    ) {
        var locationsWeather = [Int: CurrentWeatherModel]()
        var errors = [Error]()
        let group = DispatchGroup()
        let locations = cachedFavourites
        locations.forEach {
            print($0)
        }
        guard !cachedFavourites.isEmpty else { return completion(.success([]))}
        
        locations.enumerated().forEach { [weak self] (index, location) in
            group.enter()
            self?.networkQueue.async {
                self?.getCurrentWeather(for: location) { result in
                    switch result {
                    case .success(let currentWeather):
                        locationsWeather[index] = currentWeather
                    case .failure(let error):
                        errors.append(error)
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            guard
                locations.count != errors.count || locations.count == 0
            else {
                if let error = errors.first {
                    completion(.failure(error))
                }
                return
            }
            let sortedLocations = makeResultsArray(from: locationsWeather)
            completion(.success(sortedLocations))
        }
    }
    
    func getOrderedCurrentWeatherItems(
        completion: @escaping (Result<[CurrentWeatherModel], Error>) -> Void
    ) {
        var locationsWeather = [CurrentWeatherModel]()
        var errors = [Error]()
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 1)
        let locations = cachedFavourites
        for location in locations {
            group.enter()
            networkQueue.async { [weak self] in
                semaphore.wait()
                self?.getCurrentWeather(for: location) { result in
                    switch result {
                    case .success(let currentWeather):
                        locationsWeather.append(currentWeather)
                    case .failure(let error):
                        errors.append(error)
                    }
                    semaphore.signal()
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            guard locations.count != errors.count else {
                if let error = errors.first {
                    completion(.failure(error))
                }
                return
            }
            completion(.success(locationsWeather))
        }
    }
}
