//
//  WeatherDetailsViewModelFactory.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation

protocol IWeatherDetailsViewModelFactory {
    
    func makeCurrentWeatherViewModel(model: ForecastModel) -> WeatherDetailsViewModel
}

final class WeatherDetailsViewModelFactory {
    
    init() {}
    
    // MARK: - Private
    
    private func makeTempreature(_ temp: Double) -> String {
        return String(Int(temp)) + "°"
    }
}

// MARK: - IWeatherDetailsViewModelFactory

extension WeatherDetailsViewModelFactory: IWeatherDetailsViewModelFactory {
    
    func makeCurrentWeatherViewModel(model: ForecastModel) -> WeatherDetailsViewModel {
        
        return WeatherDetailsViewModel(
            currentWeatherViewModel: .init(
                location: model.currentWeather.location.name,
                currentTemp: makeTempreature(model.currentWeather.temperature),
                conditions: model.currentWeather.condition.text,
                minTemp: makeTempreature(model.forecastDays[0].maxTemp),
                maxTemp: makeTempreature(model.forecastDays[0].maxTemp)
            )
        )
    }
}
