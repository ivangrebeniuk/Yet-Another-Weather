//
//  CurrentWeatherModel+JSONParsable.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 12.06.2024.
//

import Foundation
import SwiftyJSON

// MARK: - JSONParsable

extension CurrentWeatherModel: JSONParsable {
    
    // MARK: - JSONParsable
        
    static func from(_ json: JSON) -> Self? {
        
        guard let name = json["location"]["name"].string,
              let region = json["location"]["region"].string,
              let country = json["location"]["country"].string,
              let temperature = json["current"]["temp_c"].double,
              let localTime = json["location"]["localtime_epoch"].string,
              let timeZone = json["location"]["tz_id"].string,
              let icon = json["current"]["condition"]["icon"].string,
              let iconUrl = URL(string: icon),
              let text = json["current"]["condition"]["text"].string,
              let isDay = json["current"]["is_day"].int
        else { return nil }
        
        return CurrentWeatherModel(
            temperature: temperature,
            location: .init(
                name: name,
                region: region,
                country: country,
                localTime: localTime,
                timeZone: timeZone
            ),
            condition: .init(text: text, iconUrl: iconUrl),
            isDay: isDay == 1
        )
    }
}
