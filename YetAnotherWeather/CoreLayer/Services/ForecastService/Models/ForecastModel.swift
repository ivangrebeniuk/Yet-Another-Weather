//
//  ForecastModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 24.09.2024.
//

import Foundation

struct ForecastModel {
    
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
