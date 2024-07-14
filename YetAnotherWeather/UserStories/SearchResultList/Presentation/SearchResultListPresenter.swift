//
//  SearchResultsPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 07.07.2024.
//

import Foundation

protocol ISearchResultsPresenter: AnyObject {
    
    func viewDidLoad()
}

final class SearchResultsPresenter {
    
    // Dependencies
    // private let coordinator: ICoordinator
    private let weatherNetworkService: IWeatherNetworkService
    
    weak var view: ISearchResultsView?
    
    // MARK: - Init
    
    init(
        // coordinator: ICoordinator,
        weatherNetworkService: IWeatherNetworkService
    ) {
        // self.coordinator = coordinator
        self.weatherNetworkService = weatherNetworkService
    }
    
    // MARK: - Private
    
    private func makeViewModels() {
        
    }
}


// MARK: - SearchResultListPresenter

extension SearchResultsPresenter: ISearchResultsPresenter {
    
    func viewDidLoad() {
        
    }
}
