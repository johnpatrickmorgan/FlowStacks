@testable import FlowStacks
import XCTest

final class CalculateStepsTests: XCTestCase {
  typealias RouterState = [Route<Int>]
  
  func testPushOneAtATime() {
    let start: RouterState = [
      .root(1, embedInNavigationView: true)
    ]
    let end: RouterState = [
      .root(-1, embedInNavigationView: true),
      .push(-2),
      .push(-3),
      .push(-4)
    ]
    
    let steps = RouteSteps.calculateSteps(from: start, to: end)
    
    let expectedSteps: [RouterState] = [
      [
        .root(-1, embedInNavigationView: true)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .push(-2)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .push(-2),
        .push(-3)
      ],
      end
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
  
  func testPopAllAtOnce() {
    let start: RouterState = [
      .root(1, embedInNavigationView: true),
      .push(2),
      .push(3),
      .push(4)
    ]
    let end: RouterState = [
      .root(-1, embedInNavigationView: true)
    ]
    
    let steps = RouteSteps.calculateSteps(from: start, to: end)
    
    let expectedSteps: [RouterState] = [
      [
        .root(-1, embedInNavigationView: true),
        .push(2),
        .push(3),
        .push(4)
      ],
      end
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
  
  func testPresentOneAtATime() {
    let start: RouterState = [
      .root(1, embedInNavigationView: true)
    ]
    let end: RouterState = [
      .root(-1, embedInNavigationView: true),
      .sheet(-2),
      .cover(-3),
      .sheet(-4)
    ]
    
    let steps = RouteSteps.calculateSteps(from: start, to: end)
    
    let expectedSteps: [RouterState] = [
      [
        .root(-1, embedInNavigationView: true)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .sheet(-2)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .sheet(-2),
        .cover(-3)
      ],
      end
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
  
  func testDismissOneAtATime() {
    let start: RouterState = [
      .root(1, embedInNavigationView: true),
      .sheet(2),
      .cover(3),
      .sheet(4)
    ]
    let end: RouterState = [
      .root(-1, embedInNavigationView: true)
    ]
    
    let steps = RouteSteps.calculateSteps(from: start, to: end)
    
    let expectedSteps: [RouterState] = [
      [
        .root(-1, embedInNavigationView: true),
        .sheet(2),
        .cover(3),
        .sheet(4)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .sheet(2),
        .cover(3)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .sheet(2)
      ],
      end
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
  
  func testPresentAndPushOneAtATime() {
    let start: RouterState = [
      .root(1, embedInNavigationView: true)
    ]
    let end: RouterState = [
      .root(-1, embedInNavigationView: true),
      .push(-2),
      .push(-3),
      .sheet(-4),
      .sheet(-5)
    ]
    
    let steps = RouteSteps.calculateSteps(from: start, to: end)
    
    let expectedSteps: [RouterState] = [
      [
        .root(-1, embedInNavigationView: true)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .push(-2)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .push(-2),
        .push(-3)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .push(-2),
        .push(-3),
        .sheet(-4)
      ],
      end
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
  
  func testBackToCommonAncestorFirst() {
    let start: RouterState = [
      .root(1, embedInNavigationView: true),
      .push(2),
      .push(3),
      .push(4)
    ]
    let end: RouterState = [
      .root(-1, embedInNavigationView: true),
      .push(-2),
      .push(-3),
      .sheet(-4),
      .sheet(-5)
    ]
    
    let steps = RouteSteps.calculateSteps(from: start, to: end)
    
    let expectedSteps: [RouterState] = [
      [
        .root(-1, embedInNavigationView: true),
        .push(-2),
        .push(-3),
        .push(4)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .push(-2),
        .push(-3)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .push(-2),
        .push(-3),
        .sheet(-4)
      ],
      end
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
  
  func testBackToCommonAncestorFirstWithoutPoppingWithinExtraPresentationLayers() {
    let start: RouterState = [
      .root(1, embedInNavigationView: true),
      .sheet(2),
      .push(3),
      .sheet(4),
      .push(5)
    ]
    let end: RouterState = [
      .root(-1, embedInNavigationView: true),
      .push(-2)
    ]
    
    let steps = RouteSteps.calculateSteps(from: start, to: end)
    
    let expectedSteps: [RouterState] = [
      [
        .root(-1, embedInNavigationView: true),
        .sheet(2),
        .push(3),
        .sheet(4),
        .push(5)
      ],
      [
        .root(-1, embedInNavigationView: true),
        .sheet(2),
        .push(3)
      ],
      [
        .root(-1, embedInNavigationView: true)
      ],
      end
    ]
    XCTAssertEqual(steps, expectedSteps)
  }
}
