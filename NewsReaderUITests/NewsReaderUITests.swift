//
//  NewsReaderUITests.swift
//  NewsReaderUITests
//
//  Created by Vigneswaran on 13/02/25.
//

import XCTest

final class NewsReaderUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func test_refreshFlow_displaysArticles() throws {
        // Attempt to tap the refresh button
        let refreshButton = app.buttons["RefreshButton"]
        XCTAssertTrue(refreshButton.exists, "Refresh button should exist")
        refreshButton.tap()
        
        // Wait for at least one cell in the list
        let firstCell = app.tables.cells.firstMatch
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate, evaluatedWith: firstCell, handler: nil)
        waitForExpectations(timeout: 10, handler: {_ in 
            // Verify at least one article cell appears
            XCTAssertTrue(firstCell.exists, "At least one article cell should be visible after refresh")
        })
        
        // Verify at least one article cell appears
        XCTAssertTrue(firstCell.exists, "At least one article cell should be visible after refresh")
    }
    
    @MainActor
    func test_articleDetailNavigation() {
        let firstCell = app.tables.cells.firstMatch
        
        if firstCell.waitForExistence(timeout: 5) {
            firstCell.tap()
            
            // Check a label or identifier in the detail view
            let detailTitle = app.staticTexts["DetailTitle"]
            XCTAssertTrue(detailTitle.waitForExistence(timeout: 5),
                          "Detail view should appear with a title label")
        } else {
            XCTFail("No table cell found to tap for detail navigation test")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
