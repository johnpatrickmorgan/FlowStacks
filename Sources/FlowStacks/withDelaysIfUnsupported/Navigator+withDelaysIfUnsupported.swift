import Foundation

public extension FlowNavigator {
  /// Any changes can be made to the routes array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @available(*, deprecated, message: "No longer necessary as it is taken care of automatically")
  @_disfavoredOverload
  @MainActor
  func withDelaysIfUnsupported(transform: (inout [Route<Screen>]) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = routes
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(from: start, to: end)
    guard !didUpdateSynchronously else { return }

    Task { @MainActor in
      await routesBinding.withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
      onCompletion?()
    }
  }

  /// Any changes can be made to the routes array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @available(*, deprecated, message: "No longer necessary as it is taken care of automatically")
  @MainActor
  func withDelaysIfUnsupported(transform: (inout [Route<Screen>]) -> Void) async {
    let start = routes
    let end = apply(transform, to: start)

    let didUpdateSynchronously = synchronouslyUpdateIfSupported(from: start, to: end)
    guard !didUpdateSynchronously else { return }

    await routesBinding.withDelaysIfUnsupported(transform)
  }

  private func synchronouslyUpdateIfSupported(from start: [Route<Screen>], to end: [Route<Screen>]) -> Bool {
    guard FlowPath.canSynchronouslyUpdate(from: start, to: end) else {
      return false
    }
    routes = end
    return true
  }
}
