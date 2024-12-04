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
    private let beaufortScaleResolver: IBeaufortScaleResolver
    private let dateFormatter: ICustomDateFormatter
    
    // MARK: - Init
    
    init(
        beaufortScaleResolver: IBeaufortScaleResolver,
        dateFormatter: ICustomDateFormatter
    ) {
        self.beaufortScaleResolver = beaufortScaleResolver
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
        
        let forecastHeader = WidgetHeaderView.Model(
            imageTitle: "calendar",
            headerTitleText: titleLabel
        )
        
        return ForecastViewModel(
            forecastHeader: forecastHeader,
            forecasts: forecastDays
        )
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
        let widgetHeader = WidgetHeaderView.Model(
            imageTitle: "wind",
            headerTitleText: "WIND"
        )
        return WindViewModel(
            windWidgetHeader: widgetHeader,
            summaryStatus: beaufortScaleResolver.getWindTitle(forWindSpeed: windSpeed),
            summaryDescription: beaufortScaleResolver.getWindDescription(forWindSpeed: windSpeed),
            wind: .init(title: "Wind", value: "\(windSpeed) m/s"),
            gusts: .init(title: "Gusts", value: "\(windGust) m/s"),
            windDirection: .init(title: "Direction", value: "\(degree)° \(direction)")
        )
    }
}
