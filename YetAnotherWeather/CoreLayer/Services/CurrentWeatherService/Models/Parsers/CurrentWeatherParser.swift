//
//  CurrentWeatherParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.06.2024.
//

import Foundation
import SwiftyJSON

final class CurrentWeatherParser: IJSONParser {
    
    // MARK: - IJSONParser
    
    func parse(_ json: JSON) throws -> CurrentWeatherModel {
        let windParser = WindParser()
        let locationParser = LocationParser()
        
        guard
              let temperature = json["current"]["temp_c"].double,
              let icon = json["current"]["condition"]["icon"].string,
              let iconUrl = URL(string: icon),
              let text = json["current"]["condition"]["text"].string,
              let isDay = json["current"]["is_day"].int,
              let feelsLike = json["current"]["feelslike_c"].double
        else { throw NetworkRequestError.modelParsingError(CurrentWeatherModel.self) }
        
        return CurrentWeatherModel(
            temperature: temperature,
            location: try locationParser.parse(json),
            condition: .init(text: text, iconUrl: iconUrl),
            isDay: isDay == 1,
            wind: try windParser.parse(json),
            feelsLike: feelsLike
        )
    }
}
