//
//  iOS_SDKTests.swift
//  iOS-SDKTests
//
//  Created by Balazs Vincze on 2018. 03. 05..
//  Copyright © 2018. SchedJoules. All rights reserved.
//

import XCTest

@testable import iOS_SDK

class iOS_SDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testDateLocalization() {
        //Check the device language
        let languageSetting = SettingsManager.get(type: .language)
        guard languageSetting.code == "en" else {
            XCTFail("The phone language isn't in english")
            return
        }
        
        //Set the expected result in format # days, for the test the language setting is expected in english
        let expectedResult: String = "4 days"
        
        //Set in seconds the time in the past for the date to compare. Example 3,600 == 1 hour, 360,000 == 100 hours
        let secondsInThePast: Double = 432001 //This number should be seconds and in positive
        
        //Don't edit beyond this point
        let timeInterval = TimeInterval(secondsInThePast)
        let dateToCompare = Date(timeInterval: timeInterval, since: Date())
        let result = dateToCompare.remainingTimeString()
        
        XCTAssertEqual(expectedResult, result)
    }
    
}
