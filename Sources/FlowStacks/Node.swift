import Foundation
import SwiftUI

struct Node<Screen: Hashable, Modifier: ViewModifier, ScreenModifier: ViewModifier>: View {
  @Binding var allRoutes: [Route<Screen>]
  let truncateToIndex: (Int) -> Void
  let index: Int
  let route: Route<Screen>?
  let navigationViewModifier: Modifier
  let screenModifier: ScreenModifier

  @Environment(\.useNavigationStack) var useNavigationStack

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
    return Binding(
      get: { allRoutes.count > nextPresentedIndex },
      set: { isShowing in
        guard !isShowing else { return }
        guard allRoutes.count > nextPresentedIndex else { return }
        guard isAppeared else { return }

        truncateToIndex(nextPresentedIndex)
      }
    )
  }

  var nextPresentedIndex: Int {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), useNavigationStack == .whenAvailable {
      allRoutes.indices.contains(index + 1) ? allRoutes[(index + 1)...].firstIndex(where: \.isPresented) ?? allRoutes.endIndex : allRoutes.endIndex
    } else {
      index + 1
    }
  }

  var next: some View {
    Node(allRoutes: $allRoutes, truncateToIndex: truncateToIndex, index: nextPresentedIndex /* index + 1 */, navigationViewModifier: navigationViewModifier, screenModifier: screenModifier)
  }

  var nextRouteStyle: RouteStyle? {
    allRoutes[safe: nextPresentedIndex /* index + 1 */ ]?.style
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
        .modifier(
          EmbedModifier(
            withNavigation: route.withNavigation,
            navigationViewModifier: navigationViewModifier,
            screenModifier: screenModifier,
            routes: $allRoutes,
            navigationStackIndex: index,
            isActive: isActiveBinding,
            nextRouteStyle: nextRouteStyle,
            destination: next
          )
        )
        .environment(\.routeStyle, allRoutes[safe: index]?.style)
        .environment(\.routeIndex, index)
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
