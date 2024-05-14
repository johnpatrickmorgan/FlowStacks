import Foundation
import SwiftUI

struct Node<Screen>: View {
  @Binding var allRoutes: [Route<Screen>]
  let truncateToIndex: (Int) -> Void
  let index: Int
  let route: Route<Screen>?

  // NOTE: even though this object is unused, its inclusion avoids a glitch when swiping to dismiss
  // a sheet that's been presented from a pushed screen.
  @EnvironmentObject var navigator: FlowNavigator<Screen>

  @State var isAppeared = false

  init(allRoutes: Binding<[Route<Screen>]>, truncateToIndex: @escaping (Int) -> Void, index: Int) {
    _allRoutes = allRoutes
    self.truncateToIndex = truncateToIndex
    self.index = index
    route = allRoutes.wrappedValue[safe: index]
  }

  private var isActiveBinding: Binding<Bool> {
    return Binding(
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
    Node(allRoutes: $allRoutes, truncateToIndex: truncateToIndex, index: index + 1)
  }

  var nextRouteStyle: RouteStyle? {
    allRoutes[safe: index + 1]?.style
  }

  var body: some View {
    if let route = allRoutes[safe: index] ?? route {
      DestinationBuilderView(data: route.screen)
        .show(isActive: isActiveBinding, routeStyle: nextRouteStyle, destination: next)
        .modifier(EmbedModifier(withNavigation: route.withNavigation))
        .onAppear { isAppeared = true }
        .onDisappear { isAppeared = false }
    }
  }
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
