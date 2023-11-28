import Foundation
import SwiftUI

/// The style with which a route is shown, i.e., if the route is pushed, presented
/// as a sheet or presented as a full-screen cover.
public enum RouteStyle: Hashable {
  case push, sheet(embedInNavigationView: Bool), cover(embedInNavigationView: Bool)
  
  public var isSheet: Bool {
    switch self {
    case .sheet:
      return true
    case .cover, .push:
      return false
    }
  }
  
  public var isCover: Bool {
    switch self {
    case .cover:
      return true
    case .sheet, .push:
      return false
    }
  }
}

public extension Route {
  /// Whether the route is pushed, presented as a sheet or presented as a full-screen
  /// cover.
  var style: RouteStyle {
    switch self {
    case .push:
      return .push
    case .sheet(_, let embedInNavigationView, _):
      return .sheet(embedInNavigationView: embedInNavigationView)
    case .cover(_, let embedInNavigationView, _):
      return .cover(embedInNavigationView: embedInNavigationView)
    }
  }
}

public extension Binding where Value: Collection, Value.Element: RouteProtocol {
  /// Any changes can be made to the routes passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages. An async version of this function is also available.
  @_disfavoredOverload
  @MainActor
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Route<Screen>]) -> Void, onCompletion: (() -> Void)? = nil) where Value == [Route<Screen>] {
    let start = wrappedValue
    let end = apply(transform, to: start)
    Task { @MainActor in
      await withDelaysIfUnsupported(from: start, to: end)
      onCompletion?()
    }
  }
  
  /// Any changes can be made to the routes passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @MainActor
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Route<Screen>]) -> Void) async where Value == [Route<Screen>] {
    let start = wrappedValue
    let end = apply(transform, to: start)
    
    await withDelaysIfUnsupported(from: start, to: end)
  }
  
  @MainActor
  fileprivate func withDelaysIfUnsupported<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) async where Value == [Route<Screen>] {
    let steps = RouteSteps.calculateSteps(from: start, to: end)
    
    self.wrappedValue = steps.first!
    await self.scheduleRemainingSteps(steps: Array(steps.dropFirst()))
  }
  
  @MainActor
  fileprivate func scheduleRemainingSteps<Screen>(steps: [[Route<Screen>]]) async where Value == [Route<Screen>] {
    guard let firstStep = steps.first else {
      return
    }
    self.wrappedValue = firstStep
    do {
      try await Task.sleep(nanoseconds: UInt64(0.65 * 1_000_000_000))
      await self.scheduleRemainingSteps(steps: Array(steps.dropFirst()))
    }
    catch {}
  }
}

/// A namespace to avoid polluting the global namespace with a public function.
public enum RouteSteps {
  /// Any changes can be made to the routes passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages. An async version of this function is also available.
  @_disfavoredOverload
  public static func withDelaysIfUnsupported<Screen, Owner: AnyObject>(_ owner: Owner, _ keyPath: WritableKeyPath<Owner, [Route<Screen>]>, transform: (inout [Route<Screen>]) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = owner[keyPath: keyPath]
    let end = apply(transform, to: start)
    Task { @MainActor in
      await withDelaysIfUnsupported(owner, keyPath, from: start, to: end)
      onCompletion?()
    }
  }
  
  /// Any changes can be made to the routes passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @MainActor
  public static func withDelaysIfUnsupported<Screen, Owner: AnyObject>(_ owner: Owner, _ keyPath: WritableKeyPath<Owner, [Route<Screen>]>, transform: (inout [Route<Screen>]) -> Void) async {
    let start = owner[keyPath: keyPath]
    let end = apply(transform, to: start)
    await withDelaysIfUnsupported(owner, keyPath, from: start, to: end)
  }
  
  @MainActor
  fileprivate static func withDelaysIfUnsupported<Screen, Owner: AnyObject>(_ owner: Owner, _ keyPath: WritableKeyPath<Owner, [Route<Screen>]>, from start: [Route<Screen>], to end: [Route<Screen>]) async {
    let binding = Binding(
      get: { [weak owner] in owner?[keyPath: keyPath] ?? [] },
      set: { [weak owner] in owner?[keyPath: keyPath] = $0 }
    )
    await binding.withDelaysIfUnsupported(from: start, to: end)
  }
  
  /// For a given update to an array of routes, returns the minimum intermediate steps
  /// required to ensure each update is supported by SwiftUI.
  /// - Returns: An Array of Route arrays, representing a series of permissible steps
  ///   from start to end.
  public static func calculateSteps<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) -> [[Route<Screen>]] {
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
}

private func apply<T>(_ transform: (inout T) -> Void, to input: T) -> T {
  var transformed = input
  transform(&transformed)
  return transformed
}
