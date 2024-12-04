//
//  ForecastModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 24.09.2024.
//

import Foundation

struct ForecastModel {
    
    struct ForecastDay {
        let date: String
        let lowTemp: Double
        let highTemp: Double
        let avgTemp: Double
        let condition: Condition
        let chanceOfRain: Int
    }
    
    let currentWeather: CurrentWeatherModel
    let forecastDays: [ForecastDay]
}
