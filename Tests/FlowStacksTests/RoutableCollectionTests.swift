@testable import FlowStacks
import XCTest

final class RoutableCollectionTests: XCTestCase {
  typealias RouterState = [Route<Int>]
  
  func testPopToCurrentNavigationRootPresented() {
    var routes: RouterState = [
      .sheet(-1, withNavigation: true),
      .push(-2),
      .push(-3),
      .push(-4)
    ]
    
    routes.popToCurrentNavigationRoot()
    
    let expectedResult: RouterState = [
      .sheet(-1, withNavigation: true)
    ]
    XCTAssertEqual(routes, expectedResult)
  }
  
  func testPopToCurrentNavigationRootNotPresented() {
    var routes: RouterState = [
      .push(-2),
      .push(-3),
      .push(-4)
    ]
    
    routes.popToCurrentNavigationRoot()
    
    let expectedResult: RouterState = [
    ]
    XCTAssertEqual(routes, expectedResult)
  }
  
  func testDismissAll() {
    var routes: RouterState = [
      .push(-2),
      .sheet(3, withNavigation: true),
      .sheet(4, withNavigation: true),
      .sheet(5, withNavigation: true),
      .sheet(6, withNavigation: true),
      .push(-4)
    ]
    
    routes.dismissAll()
    
    let expectedResult: RouterState = [
      .push(-2),
    ]
    XCTAssertEqual(routes, expectedResult)
  }
  
  func testDismissAllNoOpWithOnlyPushes() {
    var routes: RouterState = [
      .push(2),
      .push(3)
    ]
    
    routes.dismissAll()
    
    let expectedResult: RouterState = [
      .push(2),
      .push(3)
    ]
    XCTAssertEqual(routes, expectedResult)
  }
}
