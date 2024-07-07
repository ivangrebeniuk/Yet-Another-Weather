//
//  CurrentWeatherModel.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 12.06.2024.
//

import Foundation

struct CurrentWeatherModel: Codable {
    
    struct Location: Codable {
        let name: String
        let region: String
        let country: String
        let localTime: Int
    }
    
    let location: Location
    let tempreture: Double
    let condtions: String
}

