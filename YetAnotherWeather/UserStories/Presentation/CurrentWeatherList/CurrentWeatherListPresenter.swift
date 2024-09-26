//
//  CurrentWeatherListPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation

protocol CurrentWeatherListOutput: AnyObject {
    
    func didSelectLocation(_ location: String, output: IWeatherDetailsOutput)
}

protocol ICurrentWeatherListPresenter {
            
    func getSortedCurrentWeatherItems()
    
    func getOrderedWeatherItems()
}

class CurrentWeatherListPresenter {
    
    // Dependencies
    private let currentWeatherService: ICurrentWeatherService
    weak var output: CurrentWeatherListOutput?
    weak var view: ICurrentWeatherListView?
    
    // Models
    private var weatherToShow: [CurrentWeatherModel] = []
    private var searchResults = [SearchResultModel]()
    private var favouriteLocations = [String]()

    // MARK: - Init
    
    init(
        currentWeatherService: ICurrentWeatherService,
        output: CurrentWeatherListOutput?
    ) {
        self.currentWeatherService = currentWeatherService
        self.output = output
    }
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func getSortedCurrentWeatherItems() {
        currentWeatherService.getSortedCurrentWeatherItems(
            for: favouriteLocations
        ) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let results):
                    self?.weatherToShow = results
                    self?.weatherToShow.forEach {
                        print("!!!", $0.location.name)
                        print("!!!", $0.temperature)
                    }
                case .failure(let error):
                    print("Ошибочка: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getOrderedWeatherItems() {
        currentWeatherService.getOrderedCurrentWeatherItems(
            for: favouriteLocations
        ) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let results):
                    self?.weatherToShow = results
                    self?.weatherToShow.forEach {
                        print("!!!", $0.location.name)
                        print("!!! time: \($0.location.localTime)")
                    }
                case .failure(let error):
                    print("Ошибочка: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - SearchResultsOutput

extension CurrentWeatherListPresenter: SearchResultsOutput {
    func didSelectLocation(_ location: String) {
        print("Search Results output сработал")
        output?.didSelectLocation(location, output: self)
    }
}

// MARK: - IWeatherDetailsOutput

extension CurrentWeatherListPresenter: IWeatherDetailsOutput {
    func didAddLocationToFavourites(location: String?) {
        if let location {
            favouriteLocations.append(location)
        }
        view?.hideSearchResults()
    }
}
