public extension FlowNavigator {
  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @_disfavoredOverload
  func withDelaysIfUnsupported(transform: (inout [Route<Screen>]) -> Void, onCompletion: (() -> Void)? = nil) {
    let start = path
    let end = apply(transform, to: start)
    Task { @MainActor in
      await pathBinding.withDelaysIfUnsupported(from: start, to: end, keyPath: \.self)
      onCompletion?()
    }
  }

  /// Any changes can be made to the screens array passed to the transform closure. If those
  /// changes are not supported within a single update by SwiftUI, the changes will be
  /// applied in stages.
  @MainActor
  func withDelaysIfUnsupported(transform: (inout [Route<Screen>]) -> Void) async {
    await pathBinding.withDelaysIfUnsupported(transform)
  }
}
