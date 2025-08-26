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
        guard let app = AppManager.shared.runningApp else {
            fatalError("XCUIApplication was not launched. Run AppManager.shared.launchApp() first⚠️")
        }
        return app
    }
}
