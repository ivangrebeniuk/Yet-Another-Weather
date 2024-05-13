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
    
    weak var view: IWeatherListView?
    
    func viewDidLoad() {
        print("Cool as fuck")
    }
}
