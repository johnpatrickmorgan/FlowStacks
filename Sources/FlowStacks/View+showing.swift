import Foundation
import SwiftUI

fileprivate enum AllScreen<Screen> {
  case root
  case screen(Screen)
}

public extension View {
  /// Allows a fixed root screen to push or present a number of additional routes. This is useful if the root screen
  /// never changes.
  /// - Parameter routes: The routes to show.
  /// - Parameter embedInNavigationView: Whether to embed the root screen in a navigation view.
  /// - Parameter buildView: A viewBuilder closure to build a view for a given screen binding and index.
  /// - Returns: A view that will show the routes
  @MainActor func showing<Screen, ScreenView: View>(_ routes: Binding<[Route<Screen>]>, embedInNavigationView: Bool = false, @ViewBuilder buildViewBinding: @escaping (Binding<Screen>, Int) -> ScreenView) -> some View {
    return showing(routes, embedInNavigationView: embedInNavigationView, buildView: { _, index in
      let screenBinding = Binding<Screen>(
        get: { routes.wrappedValue[index].screen },
        set: { routes.wrappedValue[index].screen = $0 }
      )
      buildViewBinding(screenBinding, index)
    })
  }

  /// Allows a fixed root screen to push or present a number of additional routes. This is useful if the root screen
  /// never changes.
  /// - Parameter routes: The routes to show.
  /// - Parameter embedInNavigationView: Whether to embed the root screen in a navigation view.
  /// - Parameter buildView: A viewBuilder closure to build a view for a given screen and index.
  /// - Returns: A view that will show the routes
  @MainActor func showing<Screen, ScreenView: View>(_ routes: Binding<[Route<Screen>]>, embedInNavigationView: Bool = false, @ViewBuilder buildView: @escaping (Screen, Int) -> ScreenView) -> some View {
    let allScreens = Binding<[Route<AllScreen<Screen>>]>(
      get: {
        let root: Route<AllScreen<Screen>> = .root(AllScreen.root, embedInNavigationView: embedInNavigationView)
        let remainder = routes.wrappedValue.map { route in
          route.map(AllScreen<Screen>.screen)
        }
        return [root] + remainder
      },
      set: { allScreenRoutes in
        let screenRoutes = allScreenRoutes[1...]
          .compactMap { (route: Route<AllScreen<Screen>>) -> Route<Screen> in
            route.map { (allScreen: AllScreen<Screen>) -> Screen in
              guard case .screen(let screen) = allScreen else {
                fatalError("Root screen in non-root position. This should not be possible.")
              }
              return screen
            }
          }
        routes.wrappedValue = screenRoutes
      }
    )
    return Router(allScreens) { allScreen, index in
      switch allScreen {
      case .root:
        self
      case .screen(let screen):
        buildView(screen, index - 1).environmentObject(FlowNavigator<Screen>(routes))
      }
    }.environmentObject(FlowNavigator<Screen>(routes))
  }
}
