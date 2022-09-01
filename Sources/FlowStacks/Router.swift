import Foundation
import SwiftUI
import Combine

private final class RouterPathDismissalHandler: ObservableObject {

  var lastDismissedIndex: AnyPublisher<Int, Never> {
    _lastDismissedIndex.eraseToAnyPublisher()
  }

  private let _lastDismissedIndex = PassthroughSubject<Int, Never>()

  func dismissedIndex(_ index: Int) {
    _lastDismissedIndex.send(index)
  }
}

/// Router converts an array of pushed / presented routes into a view.
public struct Router<Screen, ScreenView: View>: View {
  /// The array of routes that represents the navigation stack.
  @Binding var routes: [Route<Screen>]

  @StateObject private var pathDismissHandler = RouterPathDismissalHandler()

  /// A closure that builds a `ScreenView` from a `Screen`and its index.
  @ViewBuilder var buildView: (Screen, Int) -> ScreenView

  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a `Screen` and its index.
  public init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Screen, Int) -> ScreenView) {
    self._routes = routes
    self.buildView = buildView
  }

  public var body: some View {
    routes
      .enumerated()
      .reversed()
      .reduce(Node<Screen, ScreenView>(.end, truncateToIndex: { _ in })) { nextNode, new in
        let (index, route) = new
        return Node<Screen, ScreenView>(
          .route(
            route,
            next: nextNode,
            allRoutes: $routes,
            index: index,
            buildView: { buildView($0, index) }
          ),
          truncateToIndex: { index in
            pathDismissHandler.dismissedIndex(index)
          }
        )
      }
      .onReceive(pathDismissHandler.lastDismissedIndex) { index in
        routes = Array(routes.prefix(index))
      }
  }
}

public extension Router {
  /// Initializer for creating a Router using a binding to an array of screens.
  /// - Parameters:
  ///   - stack: A binding to an array of screens.
  ///   - buildView: A closure that builds a `ScreenView` from a binding to a `Screen` and its index.
  init(_ routes: Binding<[Route<Screen>]>, @ViewBuilder buildView: @escaping (Binding<Screen>, Int) -> ScreenView) {
    self._routes = routes
    self.buildView = { _, index in
      let binding = Binding<Screen>(
        get: { routes.wrappedValue[index].screen },
        set: { routes.wrappedValue[index].screen = $0 }
      )
      return buildView(binding, index)
    }
  }
}
