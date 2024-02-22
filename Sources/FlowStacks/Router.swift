import Foundation
import SwiftUI

/// Router converts an array of pushed / presented routes into a view.
public struct Router<Screen, ScreenView: View>: View {
  /// The array of routes that represents the navigation stack.
  @Binding var routes: [Route<Screen>]

  /// A closure that builds a `ScreenView` from a `Screen`and its index.
  @ViewBuilder var buildView: (Binding<Screen>, Int) -> ScreenView

  let accentColor: Color?

  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a binding to a `Screen` and its index.
  public init(_ routes: Binding<[Route<Screen>]>, accentColor: Color? = nil, @ViewBuilder buildView: @escaping (Binding<Screen>, Int) -> ScreenView) {
    self._routes = routes
    self.buildView = buildView
      self.accentColor = accentColor
  }

  public var body: some View {
      Node(allScreens: $routes, accentColor: accentColor, truncateToIndex: { index in routes = Array(routes.prefix(index)) }, index: 0, buildView: buildView)
          .environmentObject(FlowNavigator($routes))
  }
}

public extension Router {
  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a `Screen` and its index.
  init(_ routes: Binding<[Route<Screen>]>, accentColor: Color? = nil, @ViewBuilder buildView: @escaping (Screen, Int) -> ScreenView) {
    self._routes = routes
    self.buildView = { buildView($0.wrappedValue, $1) }
    self.accentColor = accentColor
  }

  init(_ routes: Binding<[Route<Screen>]>, accentColor: Color? = nil, @ViewBuilder buildView: @escaping (Binding<Screen>) -> ScreenView) {
    self._routes = routes
    self.buildView = { screen, _ in buildView(screen) }
    self.accentColor = accentColor
  }

  init(_ routes: Binding<[Route<Screen>]>, accentColor: Color? = nil, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
    self._routes = routes
    self.buildView = { $screen, _ in buildView(screen) }
    self.accentColor = accentColor
  }
}
