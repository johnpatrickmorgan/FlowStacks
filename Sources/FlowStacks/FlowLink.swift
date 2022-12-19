import Foundation
import SwiftUI

public struct FlowLink<P, Label: View>: View {
  var value: Route<P>?
  var label: Label

  @EnvironmentObject var pathHolder: PathHolder

  public init(value: Route<P>?, @ViewBuilder label: () -> Label) {
    self.value = value
    self.label = label()
  }

  public init(_ value: P?, style: RouteStyle, @ViewBuilder label: () -> Label) {
    self.init(value: value.map { Route(screen: $0, style: style) }, label: label)
    self.label = label()
  }

  public var body: some View {
    Button(
      action: {
        guard let value = value else { return }
        pathHolder.path.wrappedValue.append(value.map { $0 as Any })
      },
      label: { label }
    )
  }
}

public extension FlowLink where Label == Text {
  init(_ titleKey: LocalizedStringKey, value: Route<P>?) {
    self.init(value: value) { Text(titleKey) }
  }

  init<S>(_ title: S, value: Route<P>?) where S: StringProtocol {
    self.init(value: value) { Text(title) }
  }
}
