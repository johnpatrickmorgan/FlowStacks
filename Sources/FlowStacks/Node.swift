import Foundation
import SwiftUI

/// A view that represents a linked list of routes, each pushing or presenting the next in
/// the list.
struct Node<Screen, V: View>: View {

  indirect enum _Node {
    case route(Route<Screen>, next: Node<Screen, V>, allRoutes: Binding<[Route<Screen>]>, index: Int, buildView: (Screen) -> V)
    case end
  }

  let node: _Node
  let truncateToIndex: (Int) -> Void

  init(_ node: _Node, truncateToIndex: @escaping (Int) -> Void) {
    self.node = node
    self.truncateToIndex = truncateToIndex
  }

  private var isActiveBinding: Binding<Bool> {
    switch node {
    case .end:
      return .constant(false)
    case let .route(_, next, allRoutes, index, _):
      switch next.node {
      case .end:
        return .constant(false)
      case .route:
        return Binding(
          get: {
            allRoutes.wrappedValue.count > index + 1
          },
          set: { isShowing in
            guard !isShowing else { return }
            guard allRoutes.wrappedValue.count > index + 1 else { return }
            truncateToIndex(index + 1)
          }
        )
      }
    }
  }

  private var pushBinding: Binding<Bool> {
    switch next?.node {
    case .route(.push, _, _, _, _):
      return isActiveBinding
    default:
      return .constant(false)
    }
  }

  private var sheetBinding: Binding<Bool> {
    switch next?.node {
    case .route(.sheet, _, _, _, _):
      return isActiveBinding
    default:
      return .constant(false)
    }
  }


  private var coverBinding: Binding<Bool> {
    switch next?.node {
    case .route(.cover, _, _, _, _):
      return isActiveBinding
    default:
      return .constant(false)
    }
  }

  private var onDismiss: (() -> Void)? {
    switch next?.node {
    case .route(.sheet(_, _, let onDismiss), _, _, _, _),
        .route(.cover(_, _, let onDismiss), _, _, _, _):
      return onDismiss
    default:
      return nil
    }
  }

  private var route: Route<Screen>? {
    switch node {
    case .end:
      return nil
    case .route(let route, _, _, _, _):
      return route
    }
  }

  private var next: Node? {
    switch node {
    case .end:
      return nil
    case .route(_, let next, _, _, _):
      return next
    }
  }

  @ViewBuilder
  private var screenView: some View {
    switch node {
    case .end:
      EmptyView()
    case .route(let route, _, _, _, let buildView):
      buildView(route.screen)
    }
  }

  @ViewBuilder
  private var unwrappedBody: some View {
    /// NOTE: On iOS 14.4 and below, a bug prevented multiple sheet/fullScreenCover modifiers being chained
    /// on the same view, so we conditionally add the sheet/cover modifiers as a workaround. See
    /// https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-14_5-release-notes
    if #available(iOS 14.5, *) {
      screenView
        .background(
          NavigationLink(destination: next, isActive: pushBinding, label: EmptyView.init)
            .hidden()
        )
        .sheet(
          isPresented: sheetBinding,
          onDismiss: onDismiss,
          content: { next }
        )
        .cover(
          isPresented: coverBinding,
          onDismiss: onDismiss,
          content: { next }
        )
    } else {
      let asSheet = next?.route?.style.isSheet ?? false
      screenView
        .background(
          NavigationLink(destination: next, isActive: pushBinding, label: EmptyView.init)
            .hidden()
        )
        .present(
          asSheet: asSheet,
          isPresented: asSheet ? sheetBinding : coverBinding,
          onDismiss: onDismiss,
          content: { next }
        )
    }
  }

  var body: some View {
    if route?.embedInNavigationView ?? false {
      NavigationView {
        unwrappedBody
      }
      .navigationViewStyle(supportedNavigationViewStyle)
    } else {
      unwrappedBody
    }
  }
}

/// There are spurious state updates when using the `column` navigation view style, so
/// the navigation view style is forced to `stack` where possible.
private var supportedNavigationViewStyle: some NavigationViewStyle {
#if os(macOS)
  .automatic
#else
  .stack
#endif
}
