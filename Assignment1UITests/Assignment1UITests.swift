import XCTest

final class Assignment1UITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunchesAndShowsMainTabs() throws {
        let app = XCUIApplication()
        app.launchArguments = launchArgumentsForStableUITests()
        app.launch()

        XCTAssertTrue(app.buttons["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Diary"].exists)
        XCTAssertTrue(app.buttons["Incidents"].exists)
        XCTAssertTrue(app.buttons["Settings"].exists)
    }

    func testCanSwitchCoreTabs() throws {
        let app = XCUIApplication()
        app.launchArguments = launchArgumentsForStableUITests()
        app.launch()

        app.buttons["Diary"].tap()
        XCTAssertTrue(app.navigationBars["Daily Diary"].waitForExistence(timeout: 3))

        app.buttons["Incidents"].tap()
        XCTAssertTrue(app.navigationBars["Incidents"].waitForExistence(timeout: 3))

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
    }

    func testQuickActionsMenuOpenAndClose() throws {
        let app = XCUIApplication()
        app.launchArguments = launchArgumentsForStableUITests()
        app.launch()

        let openQuickActions = app.buttons["Open quick actions"]
        XCTAssertTrue(openQuickActions.waitForExistence(timeout: 5))

        openQuickActions.tap()

        let closeQuickActions = app.buttons["Close quick actions"]
        XCTAssertTrue(closeQuickActions.waitForExistence(timeout: 2))

        closeQuickActions.tap()
        XCTAssertTrue(openQuickActions.waitForExistence(timeout: 2))
    }

    private func launchArgumentsForStableUITests() -> [String] {
        [
            "UITEST_MODE",
            "UITEST_SKIP_SPLASH",
            "UITEST_SKIP_ONBOARDING",
            "UITEST_RESET_DATA"
        ]
    }
}
