//
//  ForecastParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 24.09.2024.
//

import Foundation
import SwiftyJSON

final class ForecastParser: IJSONParser {
    
    func parse(_ json: JSON) throws -> ForecastModel {
        let currentWeatherParser = CurrentWeatherParser()
        
        guard let forecastDay = json["forecast"]["forecastday"].array else {
            throw NetworkRequestError.modelParsingError
        }
        
        let days: [ForecastModel.ForecastDay] = try forecastDay.map {
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

            return ForecastModel.ForecastDay(
                date: date,
                maxTemp: maxTemp,
                minTemp: minTemp,
                avgTemp: avgTemp,
                condition: .init(text: text, icon: icon))
        }
        return ForecastModel(
            currentWeather: try currentWeatherParser.parse(json),
            forecastDays: days
        )
    }
}
