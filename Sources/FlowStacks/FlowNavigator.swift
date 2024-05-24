import SwiftUI

/// A navigator to use when the `FlowStack` is initialized with a `FlowPath` binding or no binding.
public typealias FlowPathNavigator = FlowNavigator<AnyHashable>

/// An object available via the environment that gives access to the current routes array.
@MainActor
public class FlowNavigator<Screen>: ObservableObject {
  let routesBinding: Binding<[Route<Screen>]>

  /// The current routes array.
  public var routes: [Route<Screen>] {
    get { routesBinding.wrappedValue }
    set { routesBinding.wrappedValue = newValue }
  }

  init(_ routesBinding: Binding<[Route<Screen>]>) {
    self.routesBinding = routesBinding
  }
}
