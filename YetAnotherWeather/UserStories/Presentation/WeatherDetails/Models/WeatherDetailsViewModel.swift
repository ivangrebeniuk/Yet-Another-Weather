//
//  WeatherDetailsViewModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 27.10.2024.
//

import Foundation

struct WeatherDetailsViewModel {
    
    typealias CurrentWeatherViewModel = CurrentWeatherView.Model
    typealias ForecastViewModel = ForecastView.Model
    
    let currentWeatherViewModel: CurrentWeatherViewModel
    let backgroundImageTitle: String
    let forecastViewModel: ForecastViewModel
    
    init(
        currentWeatherViewModel: CurrentWeatherViewModel,
        backgroundImageTitle: String,
        forecastViewModel: ForecastViewModel
    ) {
        self.currentWeatherViewModel = currentWeatherViewModel
        self.backgroundImageTitle = backgroundImageTitle
        self.forecastViewModel = forecastViewModel
    }
}
