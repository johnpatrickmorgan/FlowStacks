import Foundation
import SwiftUI

struct Router<Screen, RootView: View>: View {
  let rootView: RootView

  @Binding var screens: [Route<Screen>]

  init(rootView: RootView, screens: Binding<[Route<Screen>]>) {
    self.rootView = rootView
    _screens = screens
  }

  var pushedScreens: some View {
    Node(allRoutes: $screens, truncateToIndex: { screens = Array(screens.prefix($0)) }, index: 0)
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
      .show(isActive: isActiveBinding, routeStyle: nextRouteStyle, destination: pushedScreens)
  }
}
