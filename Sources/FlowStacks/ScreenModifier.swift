import SwiftUI

/// Assigns required environment objects to a screen. It's not feasible to only rely on NavigationView propagating these, as a
/// nested FlowStack using its parent's navigation view would not have the child's environment objects propagated to
/// pushed screens.
struct ScreenModifier<Data: Hashable>: ViewModifier {
  var path: RoutesHolder
  var destinationBuilder: DestinationBuilderHolder
  var navigator: FlowNavigator<Data>

  func body(content: Content) -> some View {
    content
      .environmentObject(path)
      .environmentObject(Unobserved(object: path))
      .environmentObject(destinationBuilder)
      .environmentObject(navigator)
  }
}
