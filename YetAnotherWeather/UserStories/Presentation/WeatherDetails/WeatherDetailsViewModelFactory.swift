//
//  WeatherDetailsViewModelFactory.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation
// ПЕРЕДАВАТЬ isDay как параметр и взависимости от этого конфигурировать фон и цвет шрифта

private extension String {
    static let isDayImageName = "Day_BikiniBottom"
    static let isNightImageName = "Night_BikiniBottom"
}

protocol IWeatherDetailsViewModelFactory {
    
    func makeCurrentWeatherViewModel(model: ForecastModel) -> WeatherDetailsViewModel
}

final class WeatherDetailsViewModelFactory {
    
    private typealias CurrentWeatherModel = WeatherDetailsViewModel.CurrentWeatherViewModel
    private typealias ForecastViewModel = WeatherDetailsViewModel.ForecastViewModel
        
    // MARK: - Private
    
    private func makeTempreature(_ temp: Double?) -> String? {
        guard let tempreture = temp else { return nil }
        return String(Int(tempreture)) + "°"
    }
    
    private func getWeekday(from date: Date) -> String {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        
        guard !isToday else { return "Today" }
        
        let weekday = calendar.component(.weekday, from: date)
        let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return weekDays[weekday - 1]
    }
    
    private func makeCurrentWeatherViewModel(from model: ForecastModel) -> CurrentWeatherModel {
        CurrentWeatherModel(
            location: model.currentWeather.location.name,
            conditions: model.currentWeather.condition.text,
            isLightContent: model.currentWeather.isDay,
            currentTemp: makeTempreature(model.currentWeather.temperature),
            lowTemp: makeTempreature(model.forecastDays.first?.lowTemp),
            highTemp: makeTempreature(model.forecastDays.first?.highTemp)
        )
    }
    
    private func makeForecastViewModel(from model: ForecastModel) -> ForecastViewModel {
        let titleLabel = "\(model.forecastDays.count)-DAY FORECAST"
        
        let forecastDays: [SingleDayForecastView.Model] = model.forecastDays.map { day in
            let chanceOrRain: String?
            if day.daylyChanceOfRain != 0 {
                chanceOrRain = "\(day.daylyChanceOfRain)%"
            } else {
                chanceOrRain = nil
            }
            
            return SingleDayForecastView.Model(
                day: getWeekday(from: day.date),
                imageURL: day.condition.iconUrl,
                rainFallChance: chanceOrRain,
                lowLetter: "L:",
                lowTemp: "\(Int(day.lowTemp))°",
                highLetter: "H:",
                highTemp: "\(Int(day.highTemp))°"
            )
        }
        
        return ForecastViewModel(titleLabel: titleLabel, daysForecasts: forecastDays)
    }
    
    private func makeBackgroundImageTitle(from model: ForecastModel) -> String {
        if model.currentWeather.isDay {
            return .isDayImageName
        } else {
            return .isNightImageName
        }
    }
}

// MARK: - IWeatherDetailsViewModelFactory

extension WeatherDetailsViewModelFactory: IWeatherDetailsViewModelFactory {
    
    func makeCurrentWeatherViewModel(model: ForecastModel) -> WeatherDetailsViewModel {
        let currenWeatherModel = makeCurrentWeatherViewModel(from: model)
        let imageTitle = makeBackgroundImageTitle(from: model)
        let forecastModel = makeForecastViewModel(from: model)
        return WeatherDetailsViewModel(
            currentWeatherViewModel: currenWeatherModel,
            backgroundImageTitle: imageTitle,
            forecastViewModel: forecastModel
        )
    }
}
