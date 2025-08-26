//
//  BaseUITest.swift
//  YetAnotherWeatherUITests
//
//  Created by Иван Гребенюк on 02.08.2025.
//

import Swifter
import XCTest
import Foundation

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
    
    var alertsInterruptionMonitor: NSObjectProtocol?
    var httpServer: HttpDynamicStubs!
    var port: UInt16 = 8080
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        httpServer = HttpDynamicStubs()
                
        httpServer.setUp()

        sleep(3)
        
        AppManager.shared.launchApp(
            arguments: ["isUITesting"],
            environment: ["MOCK_SERVER_PORT": "\(httpServer.port)"]
        )
        
        handleLocationPermissionAlert()
    }
    
    override func tearDown() {
        app.terminate()
        AppManager.shared.terminateApp()
        httpServer.tearDown()
        super.tearDown()
    }
}

extension BaseUITest {

    func handleLocationPermissionAlert(allow: Bool = false) {
        enableAutomaticAlertAllowance(allow: allow)
        disableAutomaticAlertAllowance()
    }
    private func enableAutomaticAlertAllowance(allow: Bool) {
        let alertText = LocationPermission.AlertText.eng.rawValue
        
        alertsInterruptionMonitor = addUIInterruptionMonitor(withDescription: alertText) { [weak self] (alert) -> Bool in
            let allowButtonText = LocationPermission.AllowText.allCases.map { $0.rawValue }
            let denyButtonText = LocationPermission.DenyText.allCases.map { $0.rawValue }
            
            guard
                let allowButton = allowButtonText.map({ alert.buttons[$0] }).first(where: { $0.exists }),
                let denyButton = denyButtonText.map({ alert.buttons[$0] }).first(where: { $0.exists })
            else {
                return false
            }
            
            allow ? allowButton.tap() : denyButton.tap()
            self?.app.activate()
            return true
        }
    }
    
    private func disableAutomaticAlertAllowance() {
        guard let monitor = alertsInterruptionMonitor else { return }
        removeUIInterruptionMonitor(monitor)
        alertsInterruptionMonitor = nil
    }
}
