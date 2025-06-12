//
//  YetAnotherWeatherTests.swift
//  YetAnotherWeatherTests
//
//  Created by Иван Гребенюк on 08.03.2025.
//

import XCTest

final class MathTestsExamples: XCTestCase {
    
    func test_addTwoNumbers() {
        // given
        let a = 2
        let b = 3
        let expectedResult = 5
        
        // when
        let actualResult = a + b
        
        // then
        XCTAssertEqual(expectedResult, actualResult)
    }
    
    func test_subtractTwoNumbers() {
        // given
        let a = 2
        let b = 3
        let expectedResult = -10
        
        // when
        let actualResult = a - b
        
        // then
        XCTAssertEqual(expectedResult, actualResult)
    }
}
