//
//  BeaufortScale.swift
//  YetAnotherWeather
//
//  Created by Ivan Grebenyuk on 27.11.2024.
//

import Foundation

enum BeaufortScale {
    
    case calm
    case lightAir
    case lightBreeze
    case gentleBreeze
    case moderateBreeze
    case freshBreeze
    case strongBreeze
    case moderateGale
    case gale
    case strongGale
    case storm
    case violentStorm
    case hurricane

    var title: String {
        switch self {
        case .calm:
            return "Calm weather🧘"
        case .lightAir, .lightBreeze, .gentleBreeze, .moderateBreeze, .freshBreeze:
            return "A little windy🍃"
        case .strongBreeze, .moderateGale:
            return "Windy💨"
        case .gale, .strongGale:
            return "Strongly windy💨"
        case .storm, .violentStorm:
            return "Storm🌊"
        case .hurricane:
            return "Hurricane🌪️"
        }
    }
    
    var description: String {
        switch self {
        case .calm:
            return "No wind at all. Smoke rises vertically."
        case .lightAir:
            return "Direction shown by smoke drift."
        case .lightBreeze:
            return "Wind felt on face."
        case .gentleBreeze:
            return "Slightly windy: leaves and small twigs in constant motion."
        case .moderateBreeze:
            return "It's a little bit windy outside: wind raises dust and loose paper."
        case .freshBreeze:
            return "It is windy; you can feel it. Small trees in leaf begin to sway."
        case .strongBreeze:
            return "Wind is quite strong: umbrellas used with difficulty."
        case .moderateGale:
            return "The wind is strong. Inconvenience when walking against the wind."
        case .gale:
            return "Strong wind. It's very difficult to go against the wind."
        case .strongGale:
            return "Danger: slight structural damage (roof slates removed)."
        case .storm:
            return "Danger: structural damage. Be careful!"
        case .violentStorm:
            return "Danger: widespread damage. Run for cover!"
        case .hurricane:
            return "Devastation. Run for cover."
        }
    }
    
    static func evaluteWind(windSpeed: Double) -> Self {
        switch windSpeed {
        case 0...0.2:
            return .calm
        case 0.3...1.5:
            return .lightAir
        case 1.6...3.3:
            return .lightBreeze
        case 3.4...5.4:
            return .gentleBreeze
        case 5.5...7.9:
            return .moderateBreeze
        case 8...10.7:
            return .freshBreeze
        case 10.8...13.8:
            return .strongBreeze
        case 13.9...17.1:
            return .moderateGale
        case 17.2...20.7:
            return .gale
        case 20.8...24.4:
            return .strongGale
        case 24.5...28.4:
            return .storm
        case 28.5...32.6:
            return .violentStorm
        case 32.7...999:
            return .hurricane
        default:
            return .calm
        }
    }
}
