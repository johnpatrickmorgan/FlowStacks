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

  /// Creates a flow link that presents the view corresponding to a value.
  /// - Parameters:
  ///   - value: An optional value to present. When the user selects the link, SwiftUI stores a copy of the value. Pass a nil value to disable the link.
  ///   - style: The mode of presentation, e.g. `.push` or `.sheet`.
  ///   - label: A label that describes the view that this link presents.
  public init(value: P?, style: RouteStyle, @ViewBuilder label: () -> Label) {
    self.init(route: value.map { Route(screen: $0, style: style) }, label: label)
  }

  public var body: some View {
    // TODO: Ensure this button is styled more like a NavigationLink within a List.
    // See: https://gist.github.com/tgrapperon/034069d6116ff69b6240265132fd9ef7
    Button(
      action: {
        guard let route else { return }
        routesHolder.object.routes.append(route.erased())
      },
      label: { label }
    )
  }
}

public extension FlowLink where Label == Text {
  /// Creates a flow link that presents a destination view, with a text label that the link generates from a title string.
  /// - Parameters:
  ///   - title: A string for creating a text label.
  ///   - value: A view for the navigation link to present.
  ///   - style: The mode of presentation, e.g. `.push` or `.sheet`.
  init(_ title: some StringProtocol, value: P?, style: RouteStyle) {
    self.init(route: value.map { Route(screen: $0, style: style) }) { Text(title) }
  }

  /// Creates a flow link that presents a destination view, with a text label that the link generates from a localized string key.
  /// - Parameters:
  ///   - titleKey: A localized string key for creating a text label.
  ///   - value: A view for the navigation link to present.
  ///   - style: The mode of presentation, e.g. `.push` or `.sheet`.
  init(_ titleKey: LocalizedStringKey, value: P?, style: RouteStyle) {
    self.init(route: value.map { Route(screen: $0, style: style) }) { Text(titleKey) }
  }
}
