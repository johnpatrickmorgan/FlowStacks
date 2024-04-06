import Foundation
import SwiftUI

/// Router converts an array of pushed / presented routes into a view.
public struct Router<Screen, ScreenView: View, Modifier: ViewModifier>: View {
  /// The array of routes that represents the navigation stack.
  @Binding var routes: [Route<Screen>]

  /// A closure that builds a `ScreenView` from a `Screen`and its index.
  @ViewBuilder var buildView: (Binding<Screen>, Int) -> ScreenView

  /// A view modifier that is applied to any `NavigationView`s created by the router.
  let navigationViewModifier: Modifier

  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a binding to a `Screen` and its index.
  public init(_ routes: Binding<[Route<Screen>]>, navigationViewModifier: Modifier, @ViewBuilder buildView: @escaping (Binding<Screen>, Int) -> ScreenView) {
    _routes = routes
    self.buildView = buildView
    self.navigationViewModifier = navigationViewModifier
  }

  public var body: some View {
    Node(allScreens: $routes, truncateToIndex: { index in routes = Array(routes.prefix(index)) }, index: 0, navigationViewModifier: navigationViewModifier, buildView: buildView)
      .environmentObject(FlowNavigator($routes))
  }
}

public extension Router {
  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a `Screen` and its index.
  ///   - navigationViewModifier: Applied to each `NavigationView` created.
  init(_ routes: Binding<[Route<Screen>]>, navigationViewModifier: Modifier, @ViewBuilder buildView: @escaping (Screen, Int) -> ScreenView) {
    _routes = routes
    self.buildView = { buildView($0.wrappedValue, $1) }
    self.navigationViewModifier = navigationViewModifier
  }

  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - navigationViewModifier: Applied to each `NavigationView` created.
  ///   - buildView: A closure that builds a `ScreenView` from a `Screen` binding.
  init(_ routes: Binding<[Route<Screen>]>, navigationViewModifier: Modifier, @ViewBuilder buildView: @escaping (Binding<Screen>) -> ScreenView) {
    _routes = routes
    self.buildView = { screen, _ in buildView(screen) }
    self.navigationViewModifier = navigationViewModifier
  }

  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - navigationViewModifier: Applied to each `NavigationView` created.
  ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
  init(_ routes: Binding<[Route<Screen>]>, navigationViewModifier: Modifier, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
    _routes = routes
    self.buildView = { $screen, _ in buildView(screen) }
    self.navigationViewModifier = navigationViewModifier
  }
}

public extension Router where Modifier == UnchangedViewModifier {
  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a `Screen` and its index.
  init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Screen, Int) -> ScreenView) {
    _routes = routes
    self.buildView = { buildView($0.wrappedValue, $1) }
    navigationViewModifier = UnchangedViewModifier()
  }

  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a binding to a`Screen`.
  init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Binding<Screen>) -> ScreenView) {
    _routes = routes
    self.buildView = { screen, _ in buildView(screen) }
    navigationViewModifier = UnchangedViewModifier()
  }

  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
  init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
    _routes = routes
    self.buildView = { $screen, _ in buildView(screen) }
    navigationViewModifier = UnchangedViewModifier()
  }

  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a binding to a`Screen` and its index.
  init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Binding<Screen>, Int) -> ScreenView) {
    _routes = routes
    self.buildView = buildView
    navigationViewModifier = UnchangedViewModifier()
  }
}
