import SwiftUI

struct PushModifier<Destination: View>: ViewModifier {
  @Binding var isActive: Bool
  var destination: Destination

  @Environment(\.isWithinNavigationStack) var isWithinNavigationStack

  func body(content: Content) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 7.0, *, tvOS 14.0, *), isWithinNavigationStack {
      AnyView(
        content
          .navigationDestination(isPresented: $isActive, destination: { destination })
      )
    } else {
      AnyView(
        content
          .background(
            NavigationLink(destination: destination, isActive: $isActive, label: EmptyView.init)
              .hidden()
          )
      )
    }
  }
}

extension View {
  func push<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(PushModifier(isActive: isActive, destination: destination))
  }
}
