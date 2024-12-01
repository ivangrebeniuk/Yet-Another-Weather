//
//  WeatherDetailsViewModelFactory.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.07.2024.
//

import Foundation

private extension String {
    static let isDayImageName = "Day_BikiniBottom"
    static let isNightImageName = "Night_BikiniBottom"
}

protocol IWeatherDetailsViewModelFactory {
    
    func makeCurrentWeatherViewModel(model: ForecastModel) -> WeatherDetailsViewModel
}

final class WeatherDetailsViewModelFactory {
    
    // Typealias
    private typealias CurrentWeatherModel = WeatherDetailsViewModel.CurrentWeatherViewModel
    private typealias ForecastViewModel = WeatherDetailsViewModel.ForecastViewModel
    private typealias WindViewModel = WeatherDetailsViewModel.WindViewModel
    
    // Dependencies
    private let dateFormatter: ICustomDateFormatter
    
    // MARK: - Init
    
    init(dateFormatter: ICustomDateFormatter) {
        self.dateFormatter = dateFormatter
    }
}

// MARK: - IWeatherDetailsViewModelFactory

extension WeatherDetailsViewModelFactory: IWeatherDetailsViewModelFactory {
    
    func makeCurrentWeatherViewModel(model: ForecastModel) -> WeatherDetailsViewModel {
        let currenWeatherModel = makeCurrentWeatherViewModel(from: model)
        let imageTitle = makeBackgroundImageTitle(from: model)
        let forecastModel = makeForecastViewModel(from: model)
        let windModel = makeWindViewModel(from: model)
        return WeatherDetailsViewModel(
            currentWeatherViewModel: currenWeatherModel,
            backgroundImageTitle: imageTitle,
            forecastViewModel: forecastModel,
            windViewModel: windModel
        )
    }
}

// MARK: - Private

private extension WeatherDetailsViewModelFactory {
    
    private func makeTempreature(_ temp: Double?) -> String? {
        guard let tempreture = temp else { return nil }
        return String(Int(tempreture)) + "°"
    }
    
    private func getWeekday(from dateString: String, timeZone: String) -> String {
        guard
            let timeZone = TimeZone(identifier: timeZone),
            let date = dateFormatter.localDate(
                from: dateString,
                mask: "yyyy-MM-dd",
                timeZone: timeZone
            )
        else {
            return ""
        }
        
        var calendar = Calendar.current
        calendar.timeZone = timeZone
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
        let timeZone = model.currentWeather.location.timeZone
        let forecastDays: [SingleDayForecastView.Model] = model.forecastDays.map { day in
            let chanceOrRain: String?
            if day.chanceOfRain != 0 {
                chanceOrRain = "\(day.chanceOfRain)%"
            } else {
                chanceOrRain = nil
            }
            
            return SingleDayForecastView.Model(
                day: getWeekday(from: day.date, timeZone: timeZone),
                imageURL: day.condition.iconUrl,
                rainFallChance: chanceOrRain,
                lowTemp: "\(Int(day.lowTemp))°",
                highTemp: "\(Int(day.highTemp))°"
            )
        }
        
        return ForecastViewModel(forecastTitle: titleLabel, forecasts: forecastDays)
    }
    
    private func makeBackgroundImageTitle(from model: ForecastModel) -> String {
        if model.currentWeather.isDay {
            return .isDayImageName
        } else {
            return .isNightImageName
        }
    }
    
    private func makeWindViewModel(from model: ForecastModel) -> WindViewModel {
        let windSpeed = round(100 * model.currentWeather.wind.windSpeed) / 100
        let windGust = round(100 * model.currentWeather.wind.windGust) / 100
        let direction = model.currentWeather.wind.windDirection
        let degree = model.currentWeather.wind.windDegree
        return WindViewModel(
            title: "WIND",
            summaryStatus: BeaufortScale.evaluteWind(windSpeed: windSpeed).title,
            summaryDescription: BeaufortScale.evaluteWind(windSpeed: windSpeed).description,
            wind: .init(title: "Wind", value: "\(windSpeed) m/s"),
            gusts: .init(title: "Gusts", value: "\(windGust) m/s"),
            windDirection: .init(title: "Direction", value: "\(degree)° \(direction)")
        )
    }
}

private extension BeaufortScale {
    
    var title: String {
        switch self {
        case .calm:
            return "Calm weather 🧘"
        case .lightAir, .lightBreeze, .gentleBreeze:
            return "A little windy 🍃"
        case .moderateBreeze, .freshBreeze, .strongBreeze, .moderateGale:
            return "Windy 💨"
        case .gale, .strongGale:
            return "Strongly windy 💨"
        case .storm, .violentStorm:
            return "Storm 🌊"
        case .hurricane:
            return "Hurricane 🌪️"
        }
    }
    
    var description: String {
        switch self {
        case .calm:
            return "No wind at all. Smoke rises vertically."
        case .lightAir:
            return "Direction shown by smoke drift."
        case .lightBreeze:
            return "Wind felt on face."
        case .gentleBreeze:
            return "Slightly windy: leaves and small twigs in constant motion."
        case .moderateBreeze:
            return "It's a little bit windy outside: wind raises dust and loose paper."
        case .freshBreeze:
            return "It is windy; you can feel it. Small trees in leaf begin to sway."
        case .strongBreeze:
            return "Wind is quite strong: umbrellas used with difficulty."
        case .moderateGale:
            return "The wind is strong. Inconvenience when walking against the wind."
        case .gale:
            return "Strong wind. It's very difficult to go against the wind."
        case .strongGale:
            return "Danger: slight structural damage (roof slates removed)."
        case .storm:
            return "Danger: structural damage. Be careful!"
        case .violentStorm:
            return "Danger: widespread damage. Run for cover!"
        case .hurricane:
            return "Devastation. Run for cover."
        }
    }
}
