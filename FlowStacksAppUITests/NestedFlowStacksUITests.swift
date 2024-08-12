import XCTest

final class NestedFlowStacksUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testNestedNavigationViaPathWithFlowStack() {
    launchAndRunNestedNavigationTests(tabTitle: "FlowPath", useNavigationStack: false, app: XCUIApplication())
  }

  func testNestedNavigationViaNoneWithFlowStack() {
    launchAndRunNestedNavigationTests(tabTitle: "NoBinding", useNavigationStack: false, app: XCUIApplication())
  }

  func launchAndRunNestedNavigationTests(tabTitle: String, useNavigationStack: Bool, app: XCUIApplication) {
    if useNavigationStack {
      // This currently has no effect, but may do so in future.
      app.launchArguments = ["USE_NAVIGATIONSTACK"]
    }
    app.launch()

    let navigationTimeout = 0.8

    XCTAssertTrue(app.tabBars.buttons[tabTitle].waitForExistence(timeout: 3))
    app.tabBars.buttons[tabTitle].tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: 2))

    app.buttons["Pick a number - route 1:-1"].tap()
    XCTAssertTrue(app.navigationBars["List"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Show 1 - route 1:0"].tap()
    XCTAssertTrue(app.navigationBars["1"].waitForExistence(timeout: navigationTimeout))

    app.buttons["FlowPath Child"].tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Pick a number - route 2:-1"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["List"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Show 1 - route 2:0"].tap()
    XCTAssertTrue(app.navigationBars["1"].waitForExistence(timeout: navigationTimeout))

    app.buttons["NoBinding Child"].tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Pick a number - route 2:2"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["List"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Show 1 - route 2:3"].tap()
    XCTAssertTrue(app.navigationBars["1"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Go back to root"].tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    // Goes back to root of FlowPath child.
    XCTAssertTrue(app.buttons["Pick a number - route 2:-1"].exists)
  }
}
