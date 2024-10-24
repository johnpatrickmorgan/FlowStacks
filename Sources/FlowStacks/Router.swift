import Foundation
import SwiftUI

struct Router<Screen: Hashable, RootView: View, NavigationViewModifier: ViewModifier, ScreenModifier: ViewModifier>: View {
  let rootView: RootView
  /// A view modifier that is applied to any `NavigationView`s created by the router.
  let navigationViewModifier: NavigationViewModifier
  let screenModifier: ScreenModifier
  let withNavigation: Bool

  @Binding var screens: [Route<Screen>]

  init(rootView: RootView, navigationViewModifier: NavigationViewModifier, screenModifier: ScreenModifier, screens: Binding<[Route<Screen>]>, withNavigation: Bool) {
    self.rootView = rootView
    self.navigationViewModifier = navigationViewModifier
    self.screenModifier = screenModifier
    self.withNavigation = withNavigation
    _screens = screens
  }
  
  var nextPresentedIndex: Int {
    screens.firstIndex(where: \.isPresented) ?? screens.endIndex
  }

  var pushedScreens: some View {
    Node(allRoutes: $screens, truncateToIndex: { screens = Array(screens.prefix($0)) }, index: nextPresentedIndex, navigationViewModifier: navigationViewModifier, screenModifier: screenModifier)
  }

  private var isActiveBinding: Binding<Bool> {
    Binding(
      get: {
        // TODO:
        screens.contains(where: \.isPresented)
      },
      set: { isShowing in
        guard !isShowing else { return }
        guard !screens.isEmpty else { return }
        // TODO:
        screens = Array(screens.prefix(upTo: nextPresentedIndex))
      }
    )
  }

  var nextRouteStyle: RouteStyle? {
    screens.first(where: \.isPresented)?.style
  }

  var body: some View {
//    let _ = print(
    rootView
      .modifier(screenModifier)
      .modifier(EmbedModifier(withNavigation: withNavigation, navigationViewModifier: navigationViewModifier, routes: $screens, navigationStackIndex: -1))
      .show(isActive: isActiveBinding, routeStyle: nextRouteStyle, destination: pushedScreens)
  }
}
