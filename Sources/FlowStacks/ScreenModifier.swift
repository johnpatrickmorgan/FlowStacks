import SwiftUI

/// Assigns required environment objects to a screen. It's not feasible to only rely on NavigationView propagating these, as a
/// nested FlowStack using its parent's navigation view would not have the child's environment objects propagated to
/// pushed screens.
struct ScreenModifier<Data: Hashable>: ViewModifier {
  var path: RoutesHolder
  var destinationBuilder: DestinationBuilderHolder
  var navigator: FlowNavigator<Data>
  @Binding var externalTypedPath: [Route<Data>]
  var isNested: Bool

  func body(content: Content) -> some View {
    content
      .environmentObject(path)
      .environmentObject(Unobserved(object: path))
      .environmentObject(destinationBuilder)
      .environmentObject(navigator)
      .onChange(of: path.routes) { routes in
        guard routes != externalTypedPath.map({ $0.erased() }) else { return }
        externalTypedPath = routes.compactMap { route in
          // NOTE: Routes may have been added via other methods (e.g. `flowDestination(item: )`) but cannot be part of the typed routes array.
          guard let screen = route.screen as? Data else { return nil }
          return Route(screen: screen, style: route.style)
        }
      }
      .onChange(of: externalTypedPath) { externalTypedPath in
        guard isNested else { return }
        path.routes = externalTypedPath.map { $0.erased() }
      }
  }
}
