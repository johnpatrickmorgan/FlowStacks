import SwiftUI

extension View {
  func indexedA11y(_ id: String) -> some View {
    modifier(IndexedA11yIdModifier(id: id))
  }
}

struct IndexedA11yIdModifier: ViewModifier {
  @Environment(\.routeIndex) var routeIndex
  @Environment(\.nestingIndex) var nestingIndex
  var id: String

  func body(content: Content) -> some View {
    content.accessibilityIdentifier("\(id) - route \(nestingIndex ?? -1):\(routeIndex ?? -1)")
  }
}
