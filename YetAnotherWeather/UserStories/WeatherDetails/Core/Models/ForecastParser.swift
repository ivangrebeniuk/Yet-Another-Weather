//
//  ForecastParser.swift
//  YetAnotherWeather
//
//  Created by Иван Гребенюк on 24.08.2024.
//

import Foundation
import SwiftyJSON

final class ForecastParser {
    
    func parse(_ json: JSON) throws -> Forecast {
        let currentWeatherParser = CurrentWeatherParser()
        
        guard let forecastDay = json["forecast"]["forecastday"].array else {
            throw NetworkRequestError.modelParsingError
        }
        
        let days: [Forecast.ForecastDay] = try forecastDay.map {
            guard
                let date = $0["date_epoch"].int,
                let maxTemp = $0["day"]["maxtemp_c"].double,
                let minTemp = $0["day"]["mintemp_c"].double,
                let avgTemp = $0["day"]["avgtemp_c"].double,
                let text = $0["day"]["condition"]["text"].string,
                let icon = $0["day"]["condition"]["icon"].string
            else {
                throw NetworkRequestError.modelParsingError
            }

            return Forecast.ForecastDay(
                date: date,
                maxTemp: maxTemp,
                minTemp: minTemp,
                avgTemp: avgTemp,
                condition: .init(text: text, icon: icon))
        }
        return Forecast(
            currentWeather: try currentWeatherParser.parse(json),
            forecastDays: days
        )
    }
}
