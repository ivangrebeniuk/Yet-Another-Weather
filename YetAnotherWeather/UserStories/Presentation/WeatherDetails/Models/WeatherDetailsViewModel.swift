//
//  WeatherDetailsViewModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 27.10.2024.
//

import Foundation

struct WeatherDetailsViewModel {
    
    struct CurrentWeatherViewModel {
        let location: String
        let currentTemp: String
        let conditions: String
        let minTemp: String
        let maxTemp: String
    }
    
    let currentWeatherViewModel: CurrentWeatherViewModel
    
    init(currentWeatherViewModel: CurrentWeatherViewModel) {
        self.currentWeatherViewModel = currentWeatherViewModel
    }
}
