import SwiftUI

struct PushModifier<Destination: View>: ViewModifier {
  @Binding var isActive: Bool
  var destination: Destination

  @Environment(\.parentNavigationStackType) var parentNavigationStackType

  func body(content: Content) -> some View {
    if #available(iOS 16.0, *, macOS 13.0, *, watchOS 9.0, *, tvOS 16.0, *), parentNavigationStackType == .navigationStack {
      // NOTE: Pushing is already handled by the data binding provided to NavigationStack.
      content
    } else {
      content
        .background(
          NavigationLink(destination: destination, isActive: $isActive, label: EmptyView.init)
            .hidden()
        )
        .onChange(of: isActive) { isActive in
          if isActive, parentNavigationStackType == nil {
            print(
              """
              Attempting to push from a view that is not embedded in a navigation view. \
              Did you mean to pass `withNavigation: true` when creating the FlowStack or \
              presenting the sheet/cover?
              """
            )
          }
        }
    }
  }
}

extension View {
  func push(isActive: Binding<Bool>, destination: some View) -> some View {
    modifier(PushModifier(isActive: isActive, destination: destination))
  }
}
