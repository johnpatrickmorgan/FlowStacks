/// This provides a mechanism to store state attached to a SwiftUI view's lifecycle, without causing the view to re-render when the value changes.
class NonReactiveState<T> {
  var value: T

  init(value: T) {
    self.value = value
  }
}
