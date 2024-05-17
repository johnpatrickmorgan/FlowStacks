import SwiftUI

/// A view modifier that makes no changes to the content.
public struct UnchangedViewModifier: ViewModifier {
  public func body(content: Content) -> some View {
    content
  }
}
