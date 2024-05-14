import SwiftUI

struct SheetModifier<Destination: View>: ViewModifier {
  var isActiveBinding: Binding<Bool>
  var destination: Destination

  func body(content: Content) -> some View {
    content
      .sheet(
        isPresented: isActiveBinding,
        onDismiss: nil,
        content: {
          destination
        }
      )
  }
}

extension View {
  func sheet<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(SheetModifier(isActiveBinding: isActive, destination: destination))
  }
}
