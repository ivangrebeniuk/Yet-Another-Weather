//
//  WeatherDetailsViewModelFactory.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation
// ПЕРЕДАВАТЬ isDay как параметр и взависимости от этого конфигурировать фон и цвет шрифта

protocol IWeatherDetailsViewModelFactory {
    
    func makeCurrentWeatherViewModel(model: ForecastModel) -> WeatherDetailsViewModel
}

final class WeatherDetailsViewModelFactory {
    
    typealias CurrentWeatherModel = WeatherDetailsViewModel.CurrentWeatherViewModel
    
    // Dependencies
    private let backgroundImageResolver: IBackgroundImageResolver

    init(backgroundImageResolver: IBackgroundImageResolver) {
        self.backgroundImageResolver = backgroundImageResolver
    }
    
    // MARK: - Private
    
    private func makeTempreature(_ temp: Double?) -> String? {
        guard let tempreture = temp else { return nil }
        return String(Int(tempreture)) + "°"
    }
    
    private func makeCurrentWeatherViewModel(from model: ForecastModel) -> CurrentWeatherModel {
        return CurrentWeatherModel(
            location: model.currentWeather.location.name,
            currentTemp: makeTempreature(model.currentWeather.temperature),
            conditions: model.currentWeather.condition.text,
            minTemp: makeTempreature(model.forecastDays.first?.maxTemp),
            maxTemp: makeTempreature(model.forecastDays.first?.maxTemp)
        )
    }
    
    private func makeBackgroundImageTitle(from model: ForecastModel) -> String {
        let isDay: Bool = model.currentWeather.isDay == 1 ? true : false
        let backgroundImage = backgroundImageResolver.resolveBackgroundImage(isDay: isDay)
        return backgroundImage.weatherDetailsImageTitle
    }
}

// MARK: - IWeatherDetailsViewModelFactory

extension WeatherDetailsViewModelFactory: IWeatherDetailsViewModelFactory {
    
    func makeCurrentWeatherViewModel(model: ForecastModel) -> WeatherDetailsViewModel {
        let currenWeatherModel = makeCurrentWeatherViewModel(from: model)
        let imageTitle = makeBackgroundImageTitle(from: model)
        return WeatherDetailsViewModel(
            currentWeatherViewModel: currenWeatherModel,
            backgroundImageTitle: imageTitle
        )
    }
}
