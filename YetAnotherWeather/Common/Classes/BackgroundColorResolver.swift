//
//  BackgroundColorResolver.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 04.11.2024.
//

import Foundation

private extension String {
    static let isDayImage = "Day_BikiniBottom"
    static let isNightImage = "Night_BikiniBottom"
}

enum BackgroundImageType {
    case day
    case night
}

extension BackgroundImageType {
    
    var weatherDetailsImageTitle: String {
        switch self {
        case .day:
            return .isDayImage
        case .night:
            return .isNightImage
        }
    }
}

protocol IBackgroundImageResolver {
    /// Returns the type of image depending on isDay parameter
    func resolveBackgroundImage(isDay: Bool) -> BackgroundImageType
}

final class BackgroundImageResolver: IBackgroundImageResolver {
    func resolveBackgroundImage(isDay: Bool) -> BackgroundImageType {
        return isDay ? .day : .night
    }
}


