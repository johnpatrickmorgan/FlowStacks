import Foundation
import SwiftUI

public extension Binding where Value: Collection, Value.Element: RouteProtocol {
  /// Any changes can be made to the routes passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages. An async version of this function is also available.
  @_disfavoredOverload
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Route<Screen>]) -> Void, onCompletion: (() -> Void)? = nil) where Value == [Route<Screen>] {
    let start = wrappedValue
    let end = apply(transform, to: start)
    Task { @MainActor in
      await withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
      onCompletion?()
    }
  }

  /// Any changes can be made to the routes passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Route<Screen>]) -> Void) async where Value == [Route<Screen>] {
    let start = wrappedValue
    let end = apply(transform, to: start)

    await withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
  }
}

public extension Binding where Value == FlowPath {
  @_disfavoredOverload
  func withDelaysIfUnsupported(_ transform: (inout FlowPath) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = wrappedValue
    let end = apply(transform, to: start)
    Task { @MainActor in
      await withDelaysIfUnsupported(from: start.elements, to: end.elements, keyPath: \.elements)
      onCompletion?()
    }
  }

  /// Any changes can be made to the routes passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  func withDelaysIfUnsupported(_ transform: (inout FlowPath) -> Void) async {
    let start = wrappedValue
    let end = apply(transform, to: start)

    await withDelaysIfUnsupported(from: start.elements, to: end.elements, keyPath: \.elements)
  }
}

func apply<T>(_ transform: (inout T) -> Void, to input: T) -> T {
  var transformed = input
  transform(&transformed)
  return transformed
}

extension Binding {
  @MainActor
  func withDelaysIfUnsupported<Screen>(_ transform: (inout [Route<Screen>]) -> Void, keyPath: WritableKeyPath<Value, [Route<Screen>]>) async {
    let start = wrappedValue[keyPath: keyPath]
    let end = apply(transform, to: start)
    await withDelaysIfUnsupported(from: start, to: end, keyPath: keyPath)
  }

  @MainActor
  func withDelaysIfUnsupported<Screen>(from start: [Route<Screen>], to end: [Route<Screen>], keyPath: WritableKeyPath<Value, [Route<Screen>]>) async {
    let steps = calculateSteps(from: start, to: end)
    wrappedValue[keyPath: keyPath] = steps.first!
    await scheduleRemainingSteps(steps: Array(steps.dropFirst()), keyPath: keyPath)
  }

  @MainActor
  func scheduleRemainingSteps<Screen>(steps: [[Route<Screen>]], keyPath: WritableKeyPath<Value, [Route<Screen>]>) async {
    guard let firstStep = steps.first else {
      return
    }
    wrappedValue[keyPath: keyPath] = firstStep
    do {
      try await Task.sleep(nanoseconds: UInt64(0.65 * 1_000_000_000))
      await scheduleRemainingSteps(steps: Array(steps.dropFirst()), keyPath: keyPath)
    } catch {}
  }
}
