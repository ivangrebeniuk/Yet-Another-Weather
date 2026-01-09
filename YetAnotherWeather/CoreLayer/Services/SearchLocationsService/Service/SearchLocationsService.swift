//
//  SearchLocationsService.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 26.09.2024.
//

import Foundation

protocol ISearchLocationsService {
    
    /// Search available locations for `location`
    /// Returns array of `[SearchResultModel]`
    func getSearchResults(
        for location: String
    ) async throws -> [SearchResultModel]
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
    
    func getSearchResults(for location: String) async throws -> [SearchResultModel] {
        let request = try urlRequestsFactory.makeSearchRequest(for: location)
        let parser = SearchResultParser()
        let models = try await networkService.load(request: request, parser: parser)
        return models
    }
}
