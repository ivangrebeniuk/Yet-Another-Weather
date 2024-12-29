//
//  CurrentWeatherCellType.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 16.12.2024.
//

import Foundation

enum CurrentWeatherCellType: Hashable {
    case weather(CurrentWeatherCell.Model)
    case spacer(UUID)
}
