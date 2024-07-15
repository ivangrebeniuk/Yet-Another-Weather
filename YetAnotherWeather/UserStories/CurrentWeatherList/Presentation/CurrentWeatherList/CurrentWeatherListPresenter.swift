//
//  CurrentWeatherListPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation

protocol ICurrentWeatherListPresenter {
    
    func getSearchResults()

    func makeSearchRequestAndGetCurrentWeather()
    
    func getUnorderedWeatherItems()
    
    func getOrderedWeatherItems()
}

class CurrentWeatherListPresenter {
    
    // Dependencies
    private let coordinator: ICoordinator
    private let weatherNetworkService: IWeatherNetworkService
    
    weak var view: ICurrentWeatherListView?
    
    // Models
    private var weatherToShow: [CurrentWeatherModel] = []
    
    
    init(
        coordinator: ICoordinator,
        weatherNetworkService: IWeatherNetworkService
    ) {
        self.coordinator = coordinator
        self.weatherNetworkService = weatherNetworkService
    }
    
    // MARK: - Private
    
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func getSearchResults() {
        weatherNetworkService.getSearchResults(for: "Сан") { result in
            switch result {
            case .success(let results):
                results.forEach {
                    print("!!! ", $0.name)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getUnorderedWeatherItems() {
        weatherNetworkService.getUnorderedCurrentWeatherItems(
            for: ["Ижевск", "Глазго", "Лондон", "Токио", "Берлин"]
        ) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let results):
                    self?.weatherToShow = results
                    self?.weatherToShow.forEach {
                        print("!!!", $0.location.name)
                        print("!!!", $0.condtions)
                        print("!!!", $0.tempreture)
                    }
                case .failure(let error):
                    print("Ошибочка: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getOrderedWeatherItems() {
        weatherNetworkService.getOrderedCurrentWeatherItems(
            for: ["Ижевск", "Глазго", "Лондон", "Токио", "Берлин"]
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
    
    func makeSearchRequestAndGetCurrentWeather() {
        weatherNetworkService.searchAndGetCurrentWeather(for: "Иже") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    print(model.location.name)
                    print(model.location.region)
                    print(model.tempreture)
                    print(model.condtions)
                case .failure(let error):
                    print("Ошибочка: \(error.localizedDescription)")
                }
            }
        }
    }
}
