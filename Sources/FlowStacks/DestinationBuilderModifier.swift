import Foundation
import SwiftUI

/// Modifier for appending a new destination builder.
struct DestinationBuilderModifier<TypedData: Hashable>: ViewModifier {
  let typedDestinationBuilder: (Binding<TypedData>) -> AnyView

  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  func body(content: Content) -> some View {
    destinationBuilder.appendBuilder(typedDestinationBuilder)

    return content
      .environmentObject(destinationBuilder)
  }
}
