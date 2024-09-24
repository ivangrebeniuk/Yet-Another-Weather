//
//  CurrentWeatherListPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation

protocol CurrentWeatherListOutput: AnyObject {
    
    func didSelectFuckingLocation(_ location: String)
}

protocol ICurrentWeatherListPresenter {
            
    func getSortedCurrentWeatherItems()
    
    func getOrderedWeatherItems()
}

class CurrentWeatherListPresenter {
    
    // Dependencies
    private let weatherNetworkService: IWeatherNetworkService
    weak var output: CurrentWeatherListOutput?
    weak var view: ICurrentWeatherListView?
    
    // Models
    private var weatherToShow: [CurrentWeatherModel] = []
    private var searchResults = [SearchResult]()
    
    // MARK: - Init
    
    init(
        weatherNetworkService: IWeatherNetworkService,
        output: CurrentWeatherListOutput?
    ) {
        self.weatherNetworkService = weatherNetworkService
        self.output = output
    }
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func getSortedCurrentWeatherItems() {
        weatherNetworkService.getSortedCurrentWeatherItems(
            for: ["Ижевск", "Глазго", "Лондон", "Лас Вегас", "Берлин", "Сан Хосе"]
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
        weatherNetworkService.getOrderedCurrentWeatherItems(
            for: ["Глазго", "Oakland"]
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
        print("Current weather list output сработал")
        output?.didSelectFuckingLocation(location)
    }
}
