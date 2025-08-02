//
//  AppManager.swift
//  YetAnotherWeatherUITests
//
//  Created by Иван Гребенюк on 02.08.2025.
//

import XCTest

final class AppManager {
    static let shared = AppManager()
    private(set) var app: XCUIApplication?

    private init() {}

    func launchApp(
        arguments: [String] = [],
        environment: [String: String] = [:]
    ) {
        let newApp = XCUIApplication()
        newApp.launchArguments = arguments
        newApp.launchEnvironment = environment
        newApp.launch()
        app = newApp
    }

    func terminateApp() {
        app?.terminate()
        app = nil
    }
}
