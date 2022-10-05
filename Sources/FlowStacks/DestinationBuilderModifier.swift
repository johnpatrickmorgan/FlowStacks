import Foundation
import SwiftUI

struct DestinationBuilderModifier<TypedData>: ViewModifier {
  let typedDestinationBuilder: (TypedData, Int, RouteStyle) -> AnyView

  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder
  @EnvironmentObject var navigator: FlowNavigator<TypedData>

  func body(content: Content) -> some View {
    destinationBuilder.appendBuilder(typedDestinationBuilder)

    return content
      .environmentObject(destinationBuilder)
  }
}
