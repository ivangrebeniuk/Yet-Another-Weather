//
//  LocationPermission.swift
//  YetAnotherWeatherUITests
//
//  Created by Иван Гребенюк on 26.08.2025.
//

import XCTest

enum LocationPermission {
    
    enum AlertText: String, CaseIterable {
        case eng = "Allow “YetAnotherWeather” to use your location?"
        case rus = "Разрешить приложению «YetAnotherWeather» использовать Вашу геопозицию?"
    }
    
    enum AllowText: String, CaseIterable {
        case allowEng = "Allow While Using App"
        case allowRus = "При использовании"
    }
    
    enum DenyText: String, CaseIterable {
        case denyEng = "Don't Allow While Using App"
        case denyeRus = "Запретить"
    }
}
