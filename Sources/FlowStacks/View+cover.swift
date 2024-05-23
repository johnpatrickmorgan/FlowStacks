import SwiftUI

struct CoverModifier<Destination: View>: ViewModifier {
  var isActiveBinding: Binding<Bool>
  var destination: Destination

  func body(content: Content) -> some View {
    #if os(macOS) // Covers are unavailable on macOS
      content
        .sheet(
          isPresented: isActiveBinding,
          onDismiss: nil,
          content: { destination.environment(\.parentNavigationStackType, nil) }
        )
    #else
      if #available(iOS 14.0, tvOS 14.0, macOS 99.9, *) {
        content
          .fullScreenCover(
            isPresented: isActiveBinding,
            onDismiss: nil,
            content: { destination.environment(\.parentNavigationStackType, nil) }
          )
      } else { // Covers are unavailable on prior versions
        content
          .sheet(
            isPresented: isActiveBinding,
            onDismiss: nil,
            content: { destination.environment(\.parentNavigationStackType, nil) }
          )
      }
    #endif
  }
}

extension View {
  func cover(isActive: Binding<Bool>, destination: some View) -> some View {
    modifier(CoverModifier(isActiveBinding: isActive, destination: destination))
  }
}
