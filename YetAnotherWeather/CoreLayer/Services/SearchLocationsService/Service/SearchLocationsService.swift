//
//  SearchLocationsService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 26.09.2024.
//

import Foundation

protocol ISearchLocationsService {
    
    /// Search available locations for `location`
    func getSearchResults(
        for location: String,
        completion: @escaping (Result<[SearchResultModel], Error>) -> Void
    )
}

final class SearchLocationsService {
    
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
}

// MARK: - IWeatherNetworkService

extension SearchLocationsService: ISearchLocationsService {
    
    func getSearchResults(
        for location: String,
        completion: @escaping (Result<[SearchResultModel], Error>) -> Void
    ) {
        do {
            let request = try urlRequestsFactory.makeSearchRequest(for: location)
            networkService.loadModels(
                request: request
            ) { (result: Result<([SearchResultModel]), Error>) in
                switch result {
                case.success(let models):
                    completion(.success(models))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(NetworkRequestError.invalidURL))
        }
    }
}
