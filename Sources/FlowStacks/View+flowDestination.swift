import Foundation
import SwiftUI

public extension View {
  func flowDestination<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (D, Int, RouteStyle) -> C) -> some View {
    return modifier(
      DestinationBuilderModifier(
        typedDestinationBuilder: { data, index, style in
          AnyView(builder(data, index, style))
        }
      )
    )
  }

  func flowDestination<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (Binding<D>, Int, RouteStyle) -> C) -> some View {
    return modifier(
      DestinationBuilderBindingModifier(
        builder: { binding, index, style in
          AnyView(builder(binding, index, style))
        }
      )
    )
  }

  func flowDestination<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) -> some View {
    return flowDestination(for: pathElementType, destination: { data, _, _ in builder(data) })
  }

  func flowDestination<D: Hashable, C: View>(for pathElementType: D.Type, @ViewBuilder destination builder: @escaping (Binding<D>) -> C) -> some View {
    return flowDestination(for: pathElementType, destination: { binding, _, _ in builder(binding) })
  }
}

struct DestinationBuilderBindingModifier<TypedData: Hashable>: ViewModifier {
  let builder: (Binding<TypedData>, Int, RouteStyle) -> AnyView

  @EnvironmentObject var navigator: FlowNavigator<TypedData>

  func body(content: Content) -> some View {
    content
      .flowDestination(for: TypedData.self, destination: { (_: TypedData, index: Int, style: RouteStyle) in
        let binding = Binding(
          get: { navigator.pathBinding.wrappedValue[index].screen },
          set: { navigator.pathBinding.wrappedValue[index].screen = $0 }
        )
        builder(binding, index, style)
      })
  }
}
