import Foundation
import SwiftUI

struct Node<Screen: Hashable, Modifier: ViewModifier, ScreenModifier: ViewModifier>: View {
  @Binding var allRoutes: [Route<Screen>]
  let truncateToIndex: (Int) -> Void
  let index: Int
  let route: Route<Screen>?
  let navigationViewModifier: Modifier
  let screenModifier: ScreenModifier

  // NOTE: even though this object is unused, its inclusion avoids a glitch when swiping to dismiss
  // a sheet that's been presented from a pushed screen.
  @EnvironmentObject var navigator: FlowNavigator<Screen>

  @State var isAppeared = false

  init(allRoutes: Binding<[Route<Screen>]>, truncateToIndex: @escaping (Int) -> Void, index: Int, navigationViewModifier: Modifier, screenModifier: ScreenModifier) {
    _allRoutes = allRoutes
    self.truncateToIndex = truncateToIndex
    self.index = index
    self.navigationViewModifier = navigationViewModifier
    self.screenModifier = screenModifier
    route = allRoutes.wrappedValue[safe: index]
  }

  private var isActiveBinding: Binding<Bool> {
    Binding(
      get: { allRoutes.count > index + 1 },
      set: { isShowing in
        guard !isShowing else { return }
        guard allRoutes.count > index + 1 else { return }
        guard isAppeared else { return }
        truncateToIndex(index + 1)
      }
    )
  }

  var next: some View {
    Node(allRoutes: $allRoutes, truncateToIndex: truncateToIndex, index: index + 1, navigationViewModifier: navigationViewModifier, screenModifier: screenModifier)
  }

  var nextRouteStyle: RouteStyle? {
    allRoutes[safe: index + 1]?.style
  }

  var body: some View {
    if let route = allRoutes[safe: index] ?? route {
      let binding = Binding<AnyHashable>(get: {
        allRoutes[safe: index]?.screen ?? route.screen
      }, set: { newValue in
        guard let typedData = newValue as? Screen else { return }
        allRoutes[index].screen = typedData
      })

      DestinationBuilderView(data: binding)
        .modifier(screenModifier)
        .environment(\.routeStyle, allRoutes[safe: index]?.style)
        .environment(\.routeIndex, index)
        .show(isActive: isActiveBinding, routeStyle: nextRouteStyle, destination: next)
        .modifier(EmbedModifier(withNavigation: route.withNavigation, navigationViewModifier: navigationViewModifier))
        .onAppear { isAppeared = true }
        .onDisappear { isAppeared = false }
    }
  }
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
