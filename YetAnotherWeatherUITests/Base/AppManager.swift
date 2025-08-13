//
//  AppManager.swift
//  YetAnotherWeatherUITests
//
//  Created by Иван Гребенюк on 02.08.2025.
//

import XCTest

final class AppManager {
    static let shared = AppManager()
    private(set) var runningApp: XCUIApplication?

    private init() {}

    func launchApp(
        arguments: [String] = [],
        environment: [String: String] = [:]
    ) {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launchEnvironment = environment
        app.launch()
        runningApp = app
    }

    func terminateApp() {
        runningApp?.terminate()
        runningApp = nil
    }
}
