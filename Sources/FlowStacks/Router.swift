import Foundation
import SwiftUI

struct Router<Screen: Hashable, RootView: View, NavigationViewModifier: ViewModifier, ScreenModifier: ViewModifier>: View {
  let rootView: RootView
  /// A view modifier that is applied to any `NavigationView`s created by the router.
  let navigationViewModifier: NavigationViewModifier
  let screenModifier: ScreenModifier

  @Binding var screens: [Route<Screen>]

  init(rootView: RootView, navigationViewModifier: NavigationViewModifier, screenModifier: ScreenModifier, screens: Binding<[Route<Screen>]>) {
    self.rootView = rootView
    self.navigationViewModifier = navigationViewModifier
    self.screenModifier = screenModifier
    _screens = screens
  }

  var pushedScreens: some View {
    Node(allRoutes: $screens, truncateToIndex: { screens = Array(screens.prefix($0)) }, index: 0, navigationViewModifier: navigationViewModifier, screenModifier: screenModifier)
  }

  private var isActiveBinding: Binding<Bool> {
    Binding(
      get: { !screens.isEmpty },
      set: { isShowing in
        guard !isShowing else { return }
        guard !screens.isEmpty else { return }
        screens = []
      }
    )
  }

  var nextRouteStyle: RouteStyle? {
    screens.first?.style
  }

  var body: some View {
    rootView
      .modifier(screenModifier)
      .show(isActive: isActiveBinding, routeStyle: nextRouteStyle, destination: pushedScreens)
  }
}
