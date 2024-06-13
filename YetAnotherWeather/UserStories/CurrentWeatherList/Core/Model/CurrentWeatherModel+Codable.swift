//
//  CurrentWeatherModel+Codable.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 12.06.2024.
//

import Foundation
import SwiftyJSON

// MARK: - JSONParsable

extension CurrentWeatherModel: JSONParsable {
        
    static func from(_ json: JSON) -> Self? {
        
        let conditions = json["current"]["condition"]["text"].stringValue
        let localTime = json["location"]["localTime"].stringValue
        
        guard let name = json["location"]["name"].string,
              let region = json["location"]["region"].string,
              let country = json["location"]["country"].string,
              let tempreture = json["current"]["temp_c"].double
        else { return nil }
        
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
