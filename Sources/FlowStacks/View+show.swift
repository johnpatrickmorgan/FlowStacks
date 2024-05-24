import SwiftUI

struct ShowModifier<Destination: View>: ViewModifier {
  var isActiveBinding: Binding<Bool>
  var routeStyle: RouteStyle?
  var destination: Destination

  func isActiveBinding(enabled: Bool) -> Binding<Bool> {
    Binding {
      enabled && isActiveBinding.wrappedValue
    } set: {
      isActiveBinding.wrappedValue = $0
    }
  }

  func body(content: Content) -> some View {
    /// NOTE: On iOS 14.4 and below, a bug prevented multiple sheet/fullScreenCover modifiers being chained
    /// on the same view, so we conditionally add the sheet/cover modifiers as a workaround. See
    /// https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-14_5-release-notes
    if #available(iOS 14.5, *) {
      content
        .push(isActive: isActiveBinding(enabled: routeStyle?.isPush ?? false), destination: destination)
        .sheet(isActive: isActiveBinding(enabled: routeStyle?.isSheet ?? false), destination: destination)
        .cover(isActive: isActiveBinding(enabled: routeStyle?.isCover ?? false), destination: destination)
    } else {
      if routeStyle?.isSheet == true {
        content
          .push(isActive: routeStyle?.isPush == true ? isActiveBinding : .constant(false), destination: destination)
          .sheet(isActive: routeStyle?.isSheet == true ? isActiveBinding : .constant(false), destination: destination)
      } else {
        content
          .push(isActive: routeStyle?.isPush == true ? isActiveBinding : .constant(false), destination: destination)
          .cover(isActive: routeStyle?.isCover == true ? isActiveBinding : .constant(false), destination: destination)
      }
    }
  }
}

extension View {
  func show(isActive: Binding<Bool>, routeStyle: RouteStyle?, destination: some View) -> some View {
    modifier(ShowModifier(isActiveBinding: isActive, routeStyle: routeStyle, destination: destination))
  }
}
