import Foundation
import SwiftUI

/// When value is non-nil, shows the destination associated with its type.
public struct FlowLink<P: Hashable, Label: View>: View {
  var route: Route<P>?
  var label: Label

  @EnvironmentObject var routesHolder: Unobserved<RoutesHolder>

  init(route: Route<P>?, @ViewBuilder label: () -> Label) {
    self.route = route
    self.label = label()
  }

  public var body: some View {
    // TODO: Ensure this button is styled more like a NavigationLink within a List.
    // See: https://gist.github.com/tgrapperon/034069d6116ff69b6240265132fd9ef7
    Button(
      action: {
        guard let route = route else { return }
        routesHolder.object.routes.append(route.erased())
      },
      label: { label }
    )
  }
}

public extension FlowLink where Label == Text {
  init(value: P?, style: RouteStyle, @ViewBuilder label: () -> Label) {
    self.init(route: value.map { Route(screen: $0, style: style) }, label: label)
  }

  init<S>(_ title: S, value: P?, style: RouteStyle) where S: StringProtocol {
    self.init(route: value.map { Route(screen: $0, style: style) }) { Text(title) }
  }

  init(_ titleKey: LocalizedStringKey, value: P?, style: RouteStyle) {
    self.init(route: value.map { Route(screen: $0, style: style) }) { Text(titleKey) }
  }
}
