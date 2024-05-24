import SwiftUI

/// Embeds a view in a NavigationView or NavigationStack.
struct EmbedModifier<NavigationViewModifier: ViewModifier>: ViewModifier {
  var withNavigation: Bool
  let navigationViewModifier: NavigationViewModifier
  @Environment(\.useNavigationStack) var useNavigationStack

  @ViewBuilder
  func wrapped(content: Content) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 7.0, *, tvOS 14.0, *), useNavigationStack == .whenAvailable {
      NavigationStack { content }
        .modifier(navigationViewModifier)
        .environment(\.parentNavigationStackType, .navigationStack)
    } else {
      NavigationView { content }
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
