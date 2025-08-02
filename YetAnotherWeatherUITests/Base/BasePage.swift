//
//  BasePage.swift
//  YetAnotherWeatherUITests
//
//  Created by Иван Гребенюк on 02.08.2025.
//

import Foundation
import XCTest

protocol BasePage {
    
    var app: XCUIApplication { get }
}

extension BasePage {
    
    var app: XCUIApplication {
        guard let app = AppManager.shared.app else {
            fatalError("App not launched")
        }
        return app
    }
}
