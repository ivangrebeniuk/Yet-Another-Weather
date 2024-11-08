//
//  WeatherDetailsViewModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 27.10.2024.
//

import Foundation

struct WeatherDetailsViewModel {
    
    typealias CurrentWeatherViewModel = CurrentWeatherView.Model
    
    let currentWeatherViewModel: CurrentWeatherViewModel
    let backgroundImageTitle: String
    
    init(
        currentWeatherViewModel: CurrentWeatherViewModel,
        backgroundImageTitle: String
    ) {
        self.currentWeatherViewModel = currentWeatherViewModel
        self.backgroundImageTitle = backgroundImageTitle
    }
}
