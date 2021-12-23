import Foundation
import SwiftUI

/// The style with which a route is shown, i.e., if the route is pushed, presented
/// as a sheet or presented as a full-screen cover.
public enum RouteStyle: Hashable {
  case push, sheet(embedInNavigationView: Bool), cover(embedInNavigationView: Bool)
}

public extension Route {
  
  /// Whether the route is pushed, presented as a sheet or presented as a full-screen
  /// cover.
  var style: RouteStyle {
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
  /// Any changes can be made to the routes passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Route<Screen>]) -> Void) where Value == [Route<Screen>] {
    let start = wrappedValue
    let end: [Route<Screen>] = {
      var transformed = start
      transform(&transformed)
      return transformed
    }()
    
    let steps = calculateSteps(from: start, to: end)
    
    self.wrappedValue = steps.first!
    self.scheduleRemainingSteps(steps: Array(steps.dropFirst()))
  }
  
  fileprivate func scheduleRemainingSteps<Screen>(steps: [[Route<Screen>]]) where Value == [Route<Screen>] {
    guard let firstStep = steps.first else {
      return
    }
    self.wrappedValue = firstStep
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(650)) {
      scheduleRemainingSteps(steps: Array(steps.dropFirst()))
    }
  }
}

/// For a given update to an array of routes, returns the minimum intermediate steps
/// required to ensure each update is supported by SwiftUI.
/// - Returns: <#description#>
func calculateSteps<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) -> [[Route<Screen>]] {
  let pairs = Array(zip(start, end))
  let firstDivergingIndex = pairs.dropFirst()
    .firstIndex(where: { $0.style != $1.style }) ?? pairs.endIndex
  let firstDivergingPresentationIndex = start[firstDivergingIndex ..< start.count]
    .firstIndex(where: { $0.isPresented }) ?? start.endIndex
  
  // Initial step is to change screen content without changing navigation structure.
  let initialStep = Array(end[..<firstDivergingIndex] + start[firstDivergingIndex...])
  var steps = [initialStep]
  
  // Dismiss extraneous presented stacks.
  while var dismissStep = steps.last, dismissStep.count > firstDivergingPresentationIndex {
    var dismissed: Route<Screen>? = dismissStep.popLast()
    // Ignore pushed screens as they can be dismissed en masse.
    while dismissed?.isPresented == false, dismissStep.count > firstDivergingPresentationIndex {
      dismissed = dismissStep.popLast()
    }
    steps.append(dismissStep)
  }
  
  // Pop extraneous pushed screens.
  while var popStep = steps.last, popStep.count > firstDivergingIndex {
    var popped: Route<Screen>? = popStep.popLast()
    while popped?.style == .push, popStep.count > firstDivergingIndex, popStep.last?.style == .push {
      popped = popStep.popLast()
    }
    steps.append(popStep)
  }
  
  // Push or present each new step.
  while var newStep = steps.last, newStep.count < end.count {
    newStep.append(end[newStep.count])
    steps.append(newStep)
  }
  
  return steps
}
