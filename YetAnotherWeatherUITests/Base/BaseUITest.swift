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
        guard let app = AppManager.shared.runningApp else {
            fatalError("App not launched")
        }
        return app
    }
    
    lazy var springboard: XCUIApplication = {
        return XCUIApplication(
            bundleIdentifier: "com.apple.springboard"
        )
    }()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        AppManager.shared.launchApp(
            arguments: [],
            environment: [:]
        )
    }
    
    override func tearDown() {
        app.terminate()
        AppManager.shared.terminateApp()
        super.tearDown()
    }
}
