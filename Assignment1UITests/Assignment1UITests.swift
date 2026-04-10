import XCTest

final class Assignment1UITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCoreTabsAreVisible() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Diary"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Incidents"].exists)
        XCTAssertTrue(app.buttons["Settings"].exists)
    }

    func testCanOpenIncidentForm() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["Incidents"].waitForExistence(timeout: 5))
        app.buttons["Incidents"].tap()

        let newIncidentButton = app.buttons["New incident report"]
        XCTAssertTrue(newIncidentButton.waitForExistence(timeout: 5))
        newIncidentButton.tap()

        XCTAssertTrue(app.navigationBars["New Incident"].waitForExistence(timeout: 5))
    }
}
