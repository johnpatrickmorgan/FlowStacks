import SwiftUI

private struct OnFirstAppear: ViewModifier {
  let action: (() -> Void)?

  @State private var hasAppeared = false

  func body(content: Content) -> some View {
    content.onAppear {
      if !hasAppeared {
        hasAppeared = true
        action?()
      }
    }
  }
}

extension View {
  func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
    modifier(OnFirstAppear(action: action))
  }
}
