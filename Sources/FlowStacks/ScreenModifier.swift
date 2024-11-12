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
  // NOTE: Using `Environment(\.scenePhase)` doesn't work if the app uses UIKIt lifecycle events (via AppDelegate/SceneDelegate).
  // We do not need to re-render the view when appIsActive changes, and doing so can cause animation glitches, so it is wrapped
  // in `NonReactiveState`.
  @State var appIsActive = NonReactiveState(value: true)

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
        guard appIsActive.value else { return }
        guard path.routes != typedPath.map({ $0.erased() }) else { return }
        path.routes = typedPath.map { $0.erased() }
      }
    #if os(iOS)
      .onReceive(NotificationCenter.default.publisher(for: didBecomeActive)) { _ in
        appIsActive.value = true
        path.routes = typedPath.map { $0.erased() }
      }
      .onReceive(NotificationCenter.default.publisher(for: willResignActive)) { _ in
        appIsActive.value = false
      }
    #elseif os(tvOS)
      .onReceive(NotificationCenter.default.publisher(for: didBecomeActive)) { _ in
        appIsActive.value = true
        path.routes = typedPath.map { $0.erased() }
      }
      .onReceive(NotificationCenter.default.publisher(for: willResignActive)) { _ in
        appIsActive.value = false
      }
    #endif
  }
}

#if os(iOS)
  private let didBecomeActive = UIApplication.didBecomeActiveNotification
  private let willResignActive = UIApplication.willResignActiveNotification
#elseif os(tvOS)
  private let didBecomeActive = UIApplication.didBecomeActiveNotification
  private let willResignActive = UIApplication.willResignActiveNotification
#endif
