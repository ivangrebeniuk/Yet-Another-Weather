//
//  ForecastParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 24.09.2024.
//

import Foundation
import SwiftyJSON

final class ForecastParser: IJSONParser {
    
    // MARK: - IJSONParser
    
    func parse(_ json: JSON) throws -> ForecastModel {
        let currentWeatherParser = CurrentWeatherParser()
        
        guard let forecastDay = json["forecast"]["forecastday"].array else {
            throw NetworkRequestError.modelParsingError(ForecastModel.self)
        }
        
        let days: [ForecastModel.ForecastDay] = try forecastDay.map {
            guard
                let date = $0["date"].string,
                let maxTemp = $0["day"]["maxtemp_c"].double,
                let minTemp = $0["day"]["mintemp_c"].double,
                let avgTemp = $0["day"]["avgtemp_c"].double,
                let text = $0["day"]["condition"]["text"].string,
                let icon = $0["day"]["condition"]["icon"].string,
                let iconUrl = URL(string: "https:" + icon),
                let daylyChanceOfRain = $0["day"]["daily_chance_of_rain"].int,
                let hours = $0["hour"].array
            else {
                throw NetworkRequestError.modelParsingError(ForecastModel.self)
            }
            
            let forecastHours: [ForecastModel.ForecastHour] = try hours.map {
                guard
                    let temp = $0["temp_c"].double,
                    let time = $0["time"].string,
                    let text = $0["condition"]["text"].string,
                    let icon = $0["condition"]["icon"].string,
                    let iconURL = URL(string: "https:" + icon)
                else {
                    throw NetworkRequestError.modelParsingError(ForecastModel.self)
                }
                
                return ForecastModel.ForecastHour(
                    temp: temp,
                    time: time,
                    condition: Condition(text: text, iconUrl: iconURL)
                )
            }

            return ForecastModel.ForecastDay(
                date: date,
                lowTemp: minTemp,
                highTemp: maxTemp,
                avgTemp: avgTemp,
                condition: .init(text: text, iconUrl: iconUrl),
                chanceOfRain: daylyChanceOfRain,
                forecastHours: forecastHours
            )
        }
        return ForecastModel(
            currentWeather: try currentWeatherParser.parse(json),
            forecastDays: days
        )
    }
}
