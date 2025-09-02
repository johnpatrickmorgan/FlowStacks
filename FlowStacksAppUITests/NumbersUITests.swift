import XCTest

let navigationTimeout = 0.8

final class NumbersUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  func testNumbersTabWithoutNavigationStack() {
    testNumbersTab(useNavigationStack: false)
  }

  func testNumbersTabWithNavigationStack() {
    testNumbersTab(useNavigationStack: true)
  }

  func testNumbersTab(useNavigationStack: Bool) {
    XCUIDevice.shared.orientation = .portrait
    let app = XCUIApplication()

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

    XCTAssertTrue(app.tabBars.buttons["Numbers"].waitForExistence(timeout: 3))
    app.tabBars.buttons["Numbers"].tap()
    XCTAssertTrue(app.navigationBars["0"].waitForExistence(timeout: navigationTimeout))

    app.buttons["Push next"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["1"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (0)"].exists)

    app.buttons["Present Double (cover) from 1"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["2"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["coverWithNavigation (1)"].exists)

    app.buttons["Present Double (cover) from 2"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["4"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["coverWithNavigation (2)"].exists)

    app.buttons["Present Double (sheet) from 4"].tap()
    XCTAssertTrue(app.navigationBars["8"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["sheetWithNavigation (3)"].exists)

    app.buttons["Present Double (sheet) from 8"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["16"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["sheetWithNavigation (4)"].exists)

    app.buttons["Push next from 16"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["17"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (5)"].exists)

    app.buttons["Push next from 17"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["18"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (6)"].exists)

    app.buttons["Present Double (sheet) from 18"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["36"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["sheetWithNavigation (7)"].exists)

    app.buttons["Push next from 36"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["37"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (8)"].exists)

    app.buttons["Push next from 37"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["38"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (9)"].exists)

    app.navigationBars.buttons["37"].tap()
    XCTAssertTrue(app.navigationBars["37"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (8)"].exists)

    app.buttons["Go back from 37"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["36"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["sheetWithNavigation (7)"].exists)

    app.buttons["Go back from 36"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["18"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (6)"].exists)

    app.buttons["Go back from 18"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["17"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (5)"].exists)

    app.buttons["Present Double (sheet) from 17"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["34"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["sheetWithNavigation (6)"].exists)

    app.navigationBars["34"].swipeSheetDown()
    XCTAssertTrue(app.navigationBars["17"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["push (5)"].exists)

    app.buttons["Show red from 17"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["Color"].waitForExistence(timeout: navigationTimeout))
    XCTAssertTrue(app.staticTexts["red"].exists)
    app.navigationBars["Color"].swipeSheetDown()

    app.buttons["Go back to root from 17"].firstMatch.tap()
    XCTAssertTrue(app.navigationBars["0"].waitForExistence(timeout: navigationTimeout * 5))
  }
}

extension XCUIElement {
  func swipeSheetDown() {
    let start = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
    let end = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 8))

    start.press(forDuration: 0.05, thenDragTo: end, withVelocity: .fast, thenHoldForDuration: 0.0)
  }
}
