//
//  Forecast.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation

struct Forecast {
    
    struct ForecastDay {
        let date: Int
        let maxTemp: Double
        let minTemp: Double
        let avgTemp: Double
        let condition: Condition
    }
    
    let currentWeather: CurrentWeatherModel
    let forecastDays: [ForecastDay]
}
