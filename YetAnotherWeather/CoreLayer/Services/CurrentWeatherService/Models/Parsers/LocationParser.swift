//
//  LocationParser.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 23.11.2024.
//

import Foundation
import SwiftyJSON

final class LocationParser: IJSONParser {
    
    func parse(_ json: JSON) throws -> CurrentWeatherModel.Location {
        guard
            let name = json["location"]["name"].string,
            let region = json["location"]["region"].string,
            let country = json["location"]["country"].string,
            let localTime = json["location"]["localtime"].string,
            let timeZone = json["location"]["tz_id"].string
        else {
            throw NetworkRequestError.modelParsingError(CurrentWeatherModel.self)
        }
        
        return CurrentWeatherModel.Location(
            name: name,
            region: region,
            country: country,
            localTime: localTime,
            timeZone: timeZone
        )
    }
}
