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
    
    private let coordinator: ICoordinator
    weak var view: ICurrentWeatherListView?
    
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        print("Cool as fuck")
    }
}
