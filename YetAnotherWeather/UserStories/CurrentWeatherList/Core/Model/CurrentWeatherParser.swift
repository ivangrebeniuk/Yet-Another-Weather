//
//  CurrentWeatherParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 30.06.2024.
//

import Foundation
import SwiftyJSON

final class CurrentWeatherParser: IJSONParser {
    
    func parse(_ json: JSON) throws -> CurrentWeatherModel {
        
        guard let name = json["location"]["name"].string,
              let region = json["location"]["region"].string,
              let country = json["location"]["country"].string,
              let tempreture = json["current"]["temp_c"].double,
              let conditions = json["current"]["condition"]["text"].string,
              let localTime = json["location"]["localtime_epoch"].int
        else { throw NetworkRequestError.modelParsingError }
        
        return CurrentWeatherModel(
            location: .init(
                name: name,
                region: region,
                country: country,
                localTime: localTime
            ),
            tempreture: tempreture,
            condtions: conditions
        )
    }
}
