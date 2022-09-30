@testable import FlowStacks
import XCTest

final class RoutableCollectionTests: XCTestCase {
  typealias RouterState = [Route<Int>]
  
  func testPopToCurrentNavigationRootPresented() {
    var routes: RouterState = [
      .root(1, embedInNavigationView: true),
      .sheet(-1, embedInNavigationView: true),
      .push(-2),
      .push(-3),
      .push(-4)
    ]
    
    routes.popToCurrentNavigationRoot()
    
    let expectedResult: RouterState = [
      .root(1, embedInNavigationView: true),
      .sheet(-1, embedInNavigationView: true)
    ]
    XCTAssertEqual(routes, expectedResult)
  }
  
  func testPopToCurrentNavigationRootNotPresented() {
    var routes: RouterState = [
      .root(1, embedInNavigationView: true),
      .push(-2),
      .push(-3),
      .push(-4)
    ]
    
    routes.popToCurrentNavigationRoot()
    
    let expectedResult: RouterState = [
      .root(1, embedInNavigationView: true),
    ]
    XCTAssertEqual(routes, expectedResult)
  }
  
  func testDismissAll() {
    var routes: RouterState = [
      .root(1, embedInNavigationView: true),
      .push(-2),
      .sheet(3, embedInNavigationView: true),
      .sheet(4, embedInNavigationView: true),
      .sheet(5, embedInNavigationView: true),
      .sheet(6, embedInNavigationView: true),
      .push(-4)
    ]
    
    routes.dismissAll()
    
    let expectedResult: RouterState = [
      .root(1, embedInNavigationView: true),
      .push(-2),
    ]
    XCTAssertEqual(routes, expectedResult)
  }
  
  func testDismissAllNoOpWithOnlyPushes() {
    var routes: RouterState = [
      .root(1, embedInNavigationView: true),
      .push(2),
      .push(3)
    ]
    
    routes.dismissAll()
    
    let expectedResult: RouterState = [
      .root(1, embedInNavigationView: true),
      .push(2),
      .push(3)
    ]
    XCTAssertEqual(routes, expectedResult)
  }
}
