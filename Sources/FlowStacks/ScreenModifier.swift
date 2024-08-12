import SwiftUI

/// Assigns required environment objects to a screen. It's not feasible to only rely on NavigationView propagating these, as a
/// nested FlowStack using its parent's navigation view would not have the child's environment objects propagated to
/// pushed screens.
struct ScreenModifier<Data: Hashable>: ViewModifier {
  var path: RoutesHolder
  var destinationBuilder: DestinationBuilderHolder
  var navigator: FlowNavigator<Data>
  @Binding var typedPath: [Route<Data>]
  var nestingIndex: Int

  func body(content: Content) -> some View {
    content
      .environmentObject(path)
      .environmentObject(Unobserved(object: path))
      .environmentObject(destinationBuilder)
      .environmentObject(navigator)
      .environment(\.nestingIndex, nestingIndex)
      .onChange(of: path.routes) { routes in
        guard routes != typedPath.map({ $0.erased() }) else { return }
        typedPath = routes.compactMap { route in
          // NOTE: Routes may have been added via other methods (e.g. `flowDestination(item: )`) but cannot be part of the typed routes array.
          guard let screen = route.screen as? Data else { return nil }
          return Route(screen: screen, style: route.style)
        }
      }
      .onChange(of: typedPath) { typedPath in
        path.routes = typedPath.map { $0.erased() }
      }
      .onChange(of: path.routes) { routes in
        guard routes != typedPath.map({ $0.erased() }) else { return }
        typedPath = routes.compactMap { route in
          if let data = route.screen.base as? Data {
            return route.map { _ in data }
          } else if route.screen.base is LocalDestinationID {
            return nil
          }
          fatalError("Cannot add \(type(of: route.screen.base)) to stack of \(Data.self)")
        }
      }
  }
}
