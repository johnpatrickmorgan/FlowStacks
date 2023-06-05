import Foundation
import SwiftUI

/// An object available via the environment that gives access to the routes array and its convenience methods for
/// pushing, presenting and going back.
@MainActor
public class FlowNavigator<Screen>: ObservableObject {
  @Binding public var routes: [Route<Screen>]

  public init(_ routes: Binding<[Route<Screen>]>) {
    self._routes = routes
  }
}
