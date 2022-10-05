import SwiftUI

public typealias FlowPathNavigator = FlowNavigator<AnyHashable>

/// An object available via the environment that gives access to the current path.
@MainActor
public class FlowNavigator<Screen>: ObservableObject {
  let pathBinding: Binding<[Route<Screen>]>

  /// The current navigation path.
  public var path: [Route<Screen>] {
    get { pathBinding.wrappedValue }
    set { pathBinding.wrappedValue = newValue }
  }

  init(_ pathBinding: Binding<[Route<Screen>]>) {
    self.pathBinding = pathBinding
  }
}
