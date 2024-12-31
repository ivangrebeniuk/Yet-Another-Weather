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
    private typealias HourlyForecastViewModel = WeatherDetailsViewModel.HourlyForecastViewModel
    
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
        let hourlyForecastModel = makeHourlyForecastViewModel(from: model)
        return WeatherDetailsViewModel(
            currentWeatherViewModel: currenWeatherModel,
            backgroundImageTitle: imageTitle,
            forecastViewModel: forecastModel,
            windViewModel: windModel,
            hourlyForecastModel: hourlyForecastModel
        )
    }
}

// MARK: - Private

private extension WeatherDetailsViewModelFactory {
    
    func makeTemperature(_ temp: Double?) -> String? {
        guard let tempreture = temp else { return nil }
        return String(Int(tempreture)) + "°"
    }
    
    func getWeekday(from dateString: String, timeZone: String) -> String {
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
    
    func prepareHour(from dateString: String, mask: String, timeZone: String, needToCompare: Bool) -> String? {
        guard
            let timeZone = TimeZone(identifier: timeZone),
            let date = dateFormatter.localDate(
                from: dateString,
                mask: "yyyy-MM-dd HH:mm",
                timeZone: timeZone
            )
        else { return nil }
        
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
        let currentHour = calendar.component(.hour, from: Date())
        let hour = calendar.component(.hour, from: date)
        
        if needToCompare {
            guard hour >= currentHour else { return nil }
            return dateFormatter.timeString(from: date, mask: mask)
        } else {
            return dateFormatter.timeString(from: date, mask: mask)
        }
    }
    
    func makeCurrentWeatherViewModel(from model: ForecastModel) -> CurrentWeatherModel {
        CurrentWeatherModel(
            location: model.currentWeather.location.name,
            conditions: model.currentWeather.condition.text,
            isLightContent: model.currentWeather.isDay,
            currentTemp: makeTemperature(model.currentWeather.temperature),
            lowTemp: makeTemperature(model.forecastDays.first?.lowTemp),
            highTemp: makeTemperature(model.forecastDays.first?.highTemp)
        )
    }
    
    func makeForecastViewModel(from model: ForecastModel) -> ForecastViewModel {
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
    
    func makeBackgroundImageTitle(from model: ForecastModel) -> String {
        if model.currentWeather.isDay {
            return .isDayImageName
        } else {
            return .isNightImageName
        }
    }
    
    func makeWindViewModel(from model: ForecastModel) -> WindViewModel {
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
    
    func makeHourlyForecastViewModel(from model: ForecastModel) -> HourlyForecastViewModel {
        let currentConditions = model.forecastDays[0].forecastHours[0].condition.text
        let widgetHeader = WidgetHeaderView.Model(
            imageTitle: "watch.analog",
            headerTitleText: "It's currently: \(currentConditions)"
        )
        let forecasts = makeHourlyForecasts(from: model)
        
        return HourlyForecastViewModel(headerModel: widgetHeader, forecasts: forecasts)
    }

    func makeHourlyForecasts(from model: ForecastModel) -> [SingleHourView.Model] {
        let timeZone = model.currentWeather.location.timeZone
        var viewModels = [SingleHourView.Model]()
    
        guard model.forecastDays.count > 2 else { return [] }
    
        let today = model.forecastDays[0]
        let tomorrow = model.forecastDays[1]
    
        viewModels = makeSingleHourForecastModel(
            from: today,
            timeZone: timeZone,
            needToCompare: true
        )
        
        guard viewModels.count < 24 else { return viewModels }

        viewModels += makeSingleHourForecastModel(
            from: tomorrow,
            timeZone: timeZone,
            needToCompare: false
        )
        
        let currentHourItem = SingleHourView.Model(
            temperature: viewModels[0].temperature,
            time: "Now",
            imageURL: viewModels[0].imageURL
        )
        
        viewModels[0] = currentHourItem
        
        return Array(viewModels.prefix(24))
    }
    
    func makeSingleHourForecastModel(
        from forecastDay: ForecastModel.ForecastDay,
        timeZone: String,
        needToCompare: Bool
    ) -> [SingleHourView.Model] {
        var viewModels = [SingleHourView.Model]()
        
        forecastDay.forecastHours.forEach {
            guard
                let hour = prepareHour(
                    from: $0.time,
                    mask: "HH:mm",
                    timeZone: timeZone,
                    needToCompare: needToCompare
                ),
                let temperature = makeTemperature($0.temp)
            else { return }
            let viewModel = SingleHourView.Model(
                temperature: temperature,
                time: hour,
                imageURL: $0.condition.iconUrl
            )
            viewModels.append(viewModel)
        }
        return viewModels
    }
}
