//
//  CurrentWeatherListPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation

protocol ICurrentWeatherListPresenter {
            
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
    private var searchResults = [SearchResult]()
    
    // MARK: - Init
    
    init(
        coordinator: ICoordinator,
        weatherNetworkService: IWeatherNetworkService
    ) {
        self.coordinator = coordinator
        self.weatherNetworkService = weatherNetworkService
    }
}

// MARK: - ICurrentWeatherListPresenter

extension CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    func getUnorderedWeatherItems() {
        weatherNetworkService.getUnorderedCurrentWeatherItems(
            for: ["Ижевск", "Глазго", "Лондон", "Лас Вегас", "Берлин", "Сан Хосе"]
        ) { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let results):
                    self?.weatherToShow = results
                    self?.weatherToShow.forEach {
                        print("!!!", $0.location.name)
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
