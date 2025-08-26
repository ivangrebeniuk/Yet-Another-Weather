//
//  MainScreenTests.swift
//  YetAnotherWeatherUITests
//
//  Created by Иван Гребенюк on 03.08.2025.
//

import Swifter
import XCTest

final class MainScreenTests: BaseUITest {
    
    // MARK: - Test
    
    func test_addNewLocationToFavourits() {
        print("🚀 Starting UI test...")
        
        // Настраиваем mock маршруты
        httpServer.setUpStub(url: "/v1/search.json", fileName: "search_cupertino")
        httpServer.setUpStub(url: "/v1/current.json", fileName: "current_cupertino")
        httpServer.setUpStub(url: "/v1/forecast.json", fileName: "forecast_cupertino")
                        
        let searchTextField = app.searchFields.firstMatch
        XCTAssert(searchTextField.waitForExistence(timeout: 1.0))
        
        searchTextField.tap()
        searchTextField.typeText("Dick Francisco")
        
        app.staticTexts["Dick Francisco, United States of America"].tap()
        
        sleep(3)
        app.buttons["Add"].tap()
        
        XCTAssert(searchTextField.waitForExistence(timeout: 1.0))

        print("✅ Test completed successfully")
    }
    
    // MARK: - Private
}
