//
//  BaseUITest.swift
//  YetAnotherWeatherUITests
//
//  Created by Иван Гребенюк on 02.08.2025.
//

import Foundation
import XCTest

class BaseUITest: XCTestCase {
    
    var app: XCUIApplication {
        guard let app = AppManager.shared.app else {
            fatalError("App not launched")
        }
        return app
    }
    
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        AppManager.shared.launchApp(
            arguments: ["-UITestMode", "-ResetState"],
            environment: ["isMockMode": "true"]
        )
    }
    
    override func tearDown() {
        AppManager.shared.terminateApp()
        super.tearDown()
    }
    
}
