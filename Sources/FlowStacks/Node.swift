import Foundation
import SwiftUI

struct Node<Screen>: View {
  let allScreens: [Route<Screen>]
  let truncateToIndex: (Int) -> Void
  let index: Int
  let screen: Route<Screen>?

  @EnvironmentObject var pathHolder: PathHolder
  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  init(allScreens: [Route<Screen>], truncateToIndex: @escaping (Int) -> Void, index: Int) {
    self.allScreens = allScreens
    self.truncateToIndex = truncateToIndex
    self.index = index
    self.screen = allScreens[safe: index]
  }

  private var nextRoute: Route<Screen>? {
    return allScreens[safe: index + 1]
  }

  private var isActiveBinding: Binding<Bool> {
    return Binding(
      get: { allScreens.count > index + 1 },
      set: { isShowing in
        guard !isShowing else { return }
        guard allScreens.count > index + 1 else { return }
        truncateToIndex(index + 1)
      }
    )
  }

  private var pushBinding: Binding<Bool> {
    guard case .push = nextRoute?.style else {
      return .constant(false)
    }
    return isActiveBinding
  }

  private var sheetBinding: Binding<Bool> {
    guard case .sheet = nextRoute?.style else {
      return .constant(false)
    }
    return isActiveBinding
  }

  private var coverBinding: Binding<Bool> {
    guard case .cover = nextRoute?.style else {
      return .constant(false)
    }
    return isActiveBinding
  }

  var next: some View {
    Node(allScreens: allScreens, truncateToIndex: truncateToIndex, index: index + 1)
      .environmentObject(pathHolder)
      .environmentObject(destinationBuilder)
  }

  @ViewBuilder
  var screenView: some View {
    if let route = allScreens[safe: index] ?? screen {
      DestinationBuilderView(data: route.screen, index: index, style: route.style)
    } else {
      EmptyView()
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
          onDismiss: nil,
          content: { next }
        )
        .cover(
          isPresented: coverBinding,
          onDismiss: nil,
          content: { next }
        )
    } else {
      let asSheet = nextRoute?.style.isSheet ?? false
      screenView
        .background(
          NavigationLink(destination: next, isActive: pushBinding, label: EmptyView.init)
            .hidden()
        )
        .present(
          asSheet: asSheet,
          isPresented: asSheet ? sheetBinding : coverBinding,
          onDismiss: nil,
          content: { next }
        )
    }
  }

  var body: some View {
    if screen?.withNavigation ?? false {
      NavigationView {
        unwrappedBody
      }
      .navigationViewStyle(supportedNavigationViewStyle)
    } else {
      unwrappedBody
    }
  }
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

extension MutableCollection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    get {
      return indices.contains(index) ? self[index] : nil
    }
    set {
      guard let newValue, indices.contains(index) else { return }
      self[index] = newValue
    }
  }
}

/// There are spurious state updates when using the `column` navigation view style, so
/// the navigation view style is forced to `stack` where possible.
var supportedNavigationViewStyle: some NavigationViewStyle {
  #if os(macOS)
    .automatic
  #else
    .stack
  #endif
}
