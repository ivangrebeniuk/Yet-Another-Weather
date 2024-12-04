//
//  WindParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 23.11.2024.
//

import Foundation
import SwiftyJSON

final class WindParser: IJSONParser {
        
    // MARK: - IJSONParser
    
    func parse(_ json: JSON) throws -> CurrentWeatherModel.Wind {
        guard
            let wind = json["current"]["wind_kph"].double,
            let gust = json["current"]["gust_kph"].double,
            let windDirection = json["current"]["wind_dir"].string,
            let windDegree = json["current"]["wind_degree"].int
        else {
            throw NetworkRequestError.modelParsingError(CurrentWeatherModel.Wind.self)
        }

        return CurrentWeatherModel.Wind(
            windSpeed: wind / 3.6,
            windGust: gust / 3.6,
            windDirection: windDirection,
            windDegree: windDegree
        )
    }
}
