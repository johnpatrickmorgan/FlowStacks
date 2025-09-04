@testable import FlowStacks
import XCTest

final class ConvenienceMethodsTests: XCTestCase {
  func testGoBackToType() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.goBackTo(type: String.self)
    XCTAssertEqual(path.count, 2)
    path.goBackTo(type: Int.self)
    XCTAssertEqual(path.count, 1)
  }

  func testGoBackToInstance() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.goBackTo("non-matching")
    XCTAssertEqual(path.count, 3)
    path.goBackTo("two")
    XCTAssertEqual(path.count, 2)
    path.goBackTo(1)
    XCTAssertEqual(path.count, 1)
  }

  func testGoBackToRoot() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.goBackToRoot()
    XCTAssertEqual(path.count, 0)
  }

  func testGoBackToIndex() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.goBackTo(index: 2)
    XCTAssertEqual(path.count, 3)
    path.goBackTo(index: 1)
    XCTAssertEqual(path.count, 2)
    path.goBackTo(index: 0)
    XCTAssertEqual(path.count, 1)
    path.goBackTo(index: -1)
    XCTAssertEqual(path.count, 0)
  }

  func testPopToType() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.popTo(type: String.self)
    XCTAssertEqual(path.count, 2)
    path.popTo(type: Int.self)
    XCTAssertEqual(path.count, 1)
  }

  func testPopToInstance() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.popTo("non-matching")
    XCTAssertEqual(path.count, 3)
    path.popTo("two")
    XCTAssertEqual(path.count, 2)
    path.popTo(1)
    XCTAssertEqual(path.count, 1)
  }

  func testPopToRoot() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.popToRoot()
    XCTAssertEqual(path.count, 0)
  }

  func testPopToIndex() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.popTo(index: 2)
    XCTAssertEqual(path.count, 3)
    path.popTo(index: 1)
    XCTAssertEqual(path.count, 2)
    path.popTo(index: 0)
    XCTAssertEqual(path.count, 1)
    path.popTo(index: -1)
    XCTAssertEqual(path.count, 0)
  }

  func testPopToCurrentNavigationRootWithoutPresentedRoutes() {
    var path = FlowPath([.push(1), .push("two"), .push(true)])
    path.popToCurrentNavigationRoot()
    XCTAssertEqual(path.count, 0)
  }

  func testPopToCurrentNavigationRootWithPresentedRoutes() {
    var path = FlowPath([.push(1), .sheet("two"), .push(true)])
    path.popToCurrentNavigationRoot()
    XCTAssertEqual(path.count, 2)
  }

  func testDismissAll() {
    var path = FlowPath([.push(1), .sheet("two"), .push(3), .cover("four"), .push(5), .cover("six"), .push(7)])
    path.dismiss()
    XCTAssertEqual(path.count, 5)
    path.dismissAll()
    XCTAssertEqual(path.count, 1)
  }
}
