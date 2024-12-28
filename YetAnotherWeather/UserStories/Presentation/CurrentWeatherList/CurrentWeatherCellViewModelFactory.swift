//
//  CurrentWeatherCellViewModelFactory.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 05.12.2024.
//

import Foundation

protocol ICurrentWeatherCellViewModelFactory {
    
    func makeViewModel(model: CurrentWeatherModel) -> CurrentWeatherCell.Model
}

final class CurrentWeatherCellViewModelFactory {
    
    // Dependencies
    private let dateFormatter: ICustomDateFormatter
    
    // MARK: - Init
    
    init(dateFormatter: ICustomDateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    // MARK: Private
    
    private func makeTempreature(_ temp: Double?) -> String? {
        guard let tempreture = temp else { return nil }
        return String(Int(tempreture)) + "°"
    }
    
    private func makeCurrentTime(from dateString: String, timeZone: String) -> String {
        guard
            let timeZone = TimeZone(identifier: timeZone),
            let date = dateFormatter.localDate(
                from: dateString,
                mask: "yyyy-MM-dd HH:mm",
                timeZone: timeZone
            ) else {
            return ""
        }
        let onlyTimeString = dateFormatter.timeString(from: date, mask: "HH:mm")
        return onlyTimeString
    }
    
    private func makeFeelsLikeLabel(from temp: Double) -> String {
        return "Feels like: \(makeTempreature(temp) ?? "")"
    }
}


// MARK: - ICurrentWeatherCellViewModelFactory

extension CurrentWeatherCellViewModelFactory: ICurrentWeatherCellViewModelFactory {
    
    func makeViewModel(model: CurrentWeatherModel) -> CurrentWeatherCell.Model {
        CurrentWeatherCell.Model(
            location: model.location.name,
            temperature: makeTempreature(
                model.temperature
            ) ?? "",
            localTime: makeCurrentTime(
                from: model.location.localTime,
                timeZone: model.location.timeZone
            ),
            isDay: model.isDay,
            conditions: model.condition.text,
            feelsLike: makeFeelsLikeLabel(from: model.feelsLike)
        )
    }
}
