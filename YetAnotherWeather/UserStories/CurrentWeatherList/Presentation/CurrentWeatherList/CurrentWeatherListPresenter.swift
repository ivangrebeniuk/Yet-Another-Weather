//
//  CurrentWeatherListPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation

protocol ICurrentWeatherListPresenter {
    
    func viewDidLoad()
}

class CurrentWeatherListPresenter: ICurrentWeatherListPresenter {
    
    // Dependencies
    private let coordinator: ICoordinator
    private let weatherNetworkService: IWeatherNetworkService
    weak var view: ICurrentWeatherListView?
    
    
    init(
        coordinator: ICoordinator,
        weatherNetworkService: IWeatherNetworkService
    ) {
        self.coordinator = coordinator
        self.weatherNetworkService = weatherNetworkService
    }
    
    func viewDidLoad() {
        print("Cool as fuck")
        weatherNetworkService.getCurrentWeather(for: "Ижевск") { result in
            switch result {
            case .success(let model):
                print(model.location.name)
                print(model.location.region)
                print(model.tempreture)
                print(model.condtions)
            case .failure(let error):
                print("Ошибка нахуй: \(error.localizedDescription)")
            }
        }
    }
}
