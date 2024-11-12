import SwiftUI

/// Embeds a view in a NavigationView or NavigationStack.
struct EmbedModifier<NavigationViewModifier: ViewModifier, Data: Hashable, Destination: View>: ViewModifier {
  var withNavigation: Bool
  let navigationViewModifier: NavigationViewModifier
  @Environment(\.useNavigationStack) var useNavigationStack
  @Environment(\.routeIndex) var routeIndex
  @Binding var routes: [Route<Data>]
  let navigationStackIndex: Int
  let isActive: Binding<Bool>
  let nextRouteStyle: RouteStyle?
  let destination: Destination

  @ViewBuilder
  func wrapped(content: Content) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), useNavigationStack == .whenAvailable {
      let path = $routes[navigationStackFrom: navigationStackIndex + 1]
      NavigationStack(path: path.indexed) {
        content
          .navigationDestination(for: Indexed<Route<Data>>.self) { indexedRoute in
            let route = indexedRoute.value
            let binding = path[safe: indexedRoute.index]?.screen.erasedToAnyHashable ?? .constant(indexedRoute.value.screen)
            DestinationBuilderView(data: binding)
              .environment(\.routeStyle, route.style)
              .environment(\.routeIndex, indexedRoute.index + 1 + (routeIndex ?? -1))
          }
      }
      .show(
        isActive: isActive,
        routeStyle: nextRouteStyle,
        destination: destination
      )
      .modifier(navigationViewModifier)
      .environment(\.parentNavigationStackType, .navigationStack)
    } else {
      NavigationView {
        content
          .show(
            isActive: isActive,
            routeStyle: nextRouteStyle,
            destination: destination
          )
      }
      .modifier(navigationViewModifier)
      .navigationViewStyle(supportedNavigationViewStyle)
      .environment(\.parentNavigationStackType, .navigationView)
    }
  }

  func body(content: Content) -> some View {
    if withNavigation {
      wrapped(content: content)
    } else {
      content
        .show(
          isActive: isActive,
          routeStyle: nextRouteStyle,
          destination: destination
        )
    }
  }
}

/// There are spurious state updates when using the `column` navigation view style, so
/// the navigation view style is forced to `stack` where possible.
private var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}

struct Indexed<T: Hashable>: Hashable {
  var index: Int
  var value: T
}

extension Array where Element: Hashable {
  var indexed: [Indexed<Element>] {
    get {
      enumerated().map(Indexed.init)
    }
    set {
      self = newValue.map(\.value)
    }
  }
}
