//
//  WeatherListPresenter.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 13.05.2024.
//

import Foundation

protocol IWeatherListPresenter {
    
    func viewDidLoad()
}

class WeatherListPresenter: IWeatherListPresenter {
    
    private let coordinator: ICoordinator
    weak var view: IWeatherListView?
    
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        print("Cool as fuck")
    }
}
