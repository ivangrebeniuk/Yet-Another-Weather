//
//  WeatherDetailsViewModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 27.10.2024.
//

import Foundation

struct WeatherDetailsViewModel {
    
    // Typealias
    typealias CurrentWeatherViewModel = CurrentWeatherView.Model
    typealias ForecastViewModel = ForecastView.Model
    typealias WindViewModel = WindView.Model
    
    let currentWeatherViewModel: CurrentWeatherViewModel
    let backgroundImageTitle: String
    let forecastViewModel: ForecastViewModel
    let windViewModel: WindViewModel
    
    // MARK: - Init
    
    init(
        currentWeatherViewModel: CurrentWeatherViewModel,
        backgroundImageTitle: String,
        forecastViewModel: ForecastViewModel,
        windViewModel: WindViewModel
    ) {
        self.currentWeatherViewModel = currentWeatherViewModel
        self.backgroundImageTitle = backgroundImageTitle
        self.forecastViewModel = forecastViewModel
        self.windViewModel = windViewModel
    }
}
