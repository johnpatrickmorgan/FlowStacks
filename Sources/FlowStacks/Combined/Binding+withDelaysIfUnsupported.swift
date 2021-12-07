import Foundation
import SwiftUI

fileprivate extension Route {
  
  enum Style: Hashable {
    case push, sheet(embedInNavigationView: Bool), cover(embedInNavigationView: Bool)
  }
  
  var style: Style {
    switch self {
    case .push:
      return .push
    case .sheet(_, let embedInNavigationView):
      return .sheet(embedInNavigationView: embedInNavigationView)
    case .cover(_, let embedInNavigationView):
      return .cover(embedInNavigationView: embedInNavigationView)
    }
  }
}

public extension Binding where Value: Collection, Value.Element: RouteProtocol {
  
  func withDelaysIfUnsupported<Screen>(_ transform: (inout Array<Route<Screen>>) -> Void) where Value == Array<Route<Screen>> {
    let start = wrappedValue
    let end: [Route<Screen>] = {
      var transformed = start
      transform(&transformed)
      return transformed
    }()
    
    let steps = calculateSteps(from: start, to: end)
    
    self.wrappedValue = steps.first!
    scheduleRemainingSteps(steps: Array(steps.dropFirst()))
  }
  
  internal func scheduleRemainingSteps<Screen>(steps: [[Route<Screen>]]) where Value == Array<Route<Screen>>  {
    guard let firstStep = steps.first else {
      return
    }
    self.wrappedValue = firstStep
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(650)) {
      scheduleRemainingSteps(steps: Array(steps.dropFirst()))
    }
  }
}

func calculateSteps<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) -> [[Route<Screen>]] {
  let pairs = Array(zip(start, end))
  let firstDivergingIndex = pairs.dropFirst()
    .firstIndex(where: { $0.style != $1.style  })
  ?? pairs.endIndex
  
  let initialStep = Array(end[..<firstDivergingIndex] + start[firstDivergingIndex...])
  var steps = [initialStep]
  
  while var newStep = steps.last, newStep.count > firstDivergingIndex {
    var dismissed: Route<Screen>? = newStep.popLast()
    while dismissed?.style == .push && newStep.count > firstDivergingIndex && newStep.last?.style == .push {
      dismissed = newStep.popLast()
    }
    steps.append(newStep)
  }
  
  while var newStep = steps.last, newStep.count < end.count {
    newStep.append(end[newStep.count])
    steps.append(newStep)
  }
  
  return steps
}
