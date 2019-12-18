//
//  iOS_SDKUITests.swift
//  iOS-SDKUITests
//
//  Created by Alberto Huerdo on 12/13/19.
//  Copyright © 2019 SchedJoules. All rights reserved.
//

import XCTest

class iOS_SDKUITests: XCTestCase {

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let tabBarsQuery = app/*@START_MENU_TOKEN@*/.tabBars/*[[".otherElements[\"SJCalendarStore\"].tabBars",".tabBars"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        tabBarsQuery.buttons["Top"].tap()
        tabBarsQuery.buttons["Featured"].tap()
        app/*@START_MENU_TOKEN@*/.tables.staticTexts["MiLB"]/*[[".otherElements[\"SJCalendarStore\"].tables",".cells.staticTexts[\"MiLB\"]",".staticTexts[\"MiLB\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.navigationBars["MiLB"]/*[[".otherElements[\"SJCalendarStore\"].navigationBars[\"MiLB\"]",".navigationBars[\"MiLB\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Featured"].tap()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    var app: XCUIApplication!

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()

        // Since UI tests are more expensive to run, it's usually a good idea
        // to exit if a failure was encountered
        continueAfterFailure = false

        app = XCUIApplication()
    }

    // MARK: - Tests

    func testGoingThroughOnboarding() {
        // We send a command line argument to our app,
        // to enable it to reset its state
        app.launchArguments.append("--uitesting")
        
        app.launch()

        // Make sure we're displaying onboarding
        XCTAssertTrue(app.isDisplayingIntroPages)

        // Swipe left three times to go through the pages
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()

        // Tap the "Done" button
        app.buttons["Start"].tap()

        // Onboarding should no longer be displayed
        XCTAssertTrue(app.isDisplayingCalendarStore)
    }

    func testSelectingCalendar() {
        app.launch()
        
        XCTAssertTrue(app.isDisplayingCalendarStore)
        
        app.tables.cells.staticTexts["Public Holidays"].tap()
        
        sleep(5)
        
        XCTAssertTrue(app.isDisplayingCalendarItem)
    }

    func testSelectingWeather() {
        app.launch()
        
        XCTAssertTrue(app.isDisplayingCalendarStore)
        
        app.tables.cells.staticTexts["City Weather"].tap()
        
        sleep(5)
        
        XCTAssertTrue(app.isDisplayingCalendarItem)
    }
    
}


extension XCUIApplication {
    
    var isDisplayingIntroPages: Bool {
        return otherElements["SJIntroPages"].exists
    }
    
    var isDisplayingCalendarStore: Bool {
        return otherElements["SJCalendarStore"].exists
    }
    
    var isDisplayingCalendarPage: Bool {
        return otherElements["SJCalendarPage"].exists
    }
    
    var isDisplayingCalendarItem: Bool {
        return otherElements["SJCalendarItem"].exists
    }
    
    var isDisplayingWeatherItem: Bool {
        return otherElements["SJWeatherItem"].exists
    }
    
}
