import XCTest

final class NestedFlowStacksUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testNestedNavigationViaPathWithNavigationView() {
    launchAndRunNestedNavigationTests(tabTitle: "FlowPath", useNavigationStack: false, app: XCUIApplication())
  }

  func testNestedNavigationViaNoneWithNavigationView() {
    launchAndRunNestedNavigationTests(tabTitle: "NoBinding", useNavigationStack: false, app: XCUIApplication())
  }

  func testNestedNavigationViaArrayWithNavigationView() {
    launchAndRunNestedNavigationTests(tabTitle: "ArrayBinding", useNavigationStack: false, app: XCUIApplication())
  }

  func testNestedNavigationViaPathWithNavigationStack() {
    launchAndRunNestedNavigationTests(tabTitle: "FlowPath", useNavigationStack: true, app: XCUIApplication())
  }

  func testNestedNavigationViaNoneWithNavigationStack() {
    launchAndRunNestedNavigationTests(tabTitle: "NoBinding", useNavigationStack: true, app: XCUIApplication())
  }

  func testNestedNavigationViaArrayWithNavigationStack() {
    launchAndRunNestedNavigationTests(tabTitle: "ArrayBinding", useNavigationStack: true, app: XCUIApplication())
  }

  func launchAndRunNestedNavigationTests(tabTitle: String, useNavigationStack: Bool, app: XCUIApplication) {
    if useNavigationStack {
      if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *) {
        app.launchArguments = ["USE_NAVIGATIONSTACK"]
      } else {
        // Navigation Stack unavailable, so test can be skipped
        return
      }
    } else if #available(iOS 26.0, *, macOS 26.0, *, watchOS 26.0, *, tvOS 26.0, *) {
      // NavigationView has issues on v26.0, so it is not supported.
      return
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

    app.buttons["FlowPath Child - route 1:1"].tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Pick a number - route 2:-1"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["List"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Show 1 - route 2:0"].tap()
    XCTAssertTrue(app.navigationBars["1"].waitForExistence(timeout: navigationTimeout))

    app.buttons["NoBinding Child - route 2:1"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Pick a number - route 2:2"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["List"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Show 1 - route 2:3"].tap()
    XCTAssertTrue(app.navigationBars["1"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Go back to root - route 2:4"].tap()
    XCTAssertTrue(app.navigationBars["Home"].waitForExistence(timeout: navigationTimeout))

    // Goes back to root of FlowPath child.
    XCTAssertTrue(app.buttons["Pick a number - route 2:-1"].exists)
  }
}
