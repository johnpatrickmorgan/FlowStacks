import Foundation
import SwiftUI

/// An object available via the environment that gives access to the routes array and its convenience methods for
/// pushing, presenting and going back.
@MainActor
public class FlowNavigator<Screen>: ObservableObject {
  var routesBinding: Binding<[Route<Screen>]>

  public var routes: [Route<Screen>] {
    get { routesBinding.wrappedValue }
    set { routesBinding.wrappedValue = newValue }
  }

  public init(_ routesBinding: Binding<[Route<Screen>]>) {
    self.routesBinding = routesBinding
  }
}
