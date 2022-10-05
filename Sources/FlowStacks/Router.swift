import Foundation
import SwiftUI

struct Router<Screen, RootView: View>: View {
  let rootView: RootView
  let withNavigation: Bool

  @Binding var screens: [Route<Screen>]
  @EnvironmentObject var pathHolder: PathHolder
  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  public init(rootView: RootView, screens: Binding<[Route<Screen>]>, withNavigation: Bool = false) {
    self.rootView = rootView
    self._screens = screens
    self.withNavigation = withNavigation
  }

  var pushedScreens: some View {
    Node(allScreens: screens, truncateToIndex: { screens = Array(screens.prefix($0)) }, index: 0)
      .environmentObject(pathHolder)
      .environmentObject(destinationBuilder)
  }

  private var nextRoute: Route<Screen>? {
    return screens.first
  }

  private var isActiveBinding: Binding<Bool> {
    screens.isEmpty ? .constant(false) : Binding(
      get: { !screens.isEmpty },
      set: { isShowing in
        guard !isShowing else { return }
        guard !screens.isEmpty else { return }
        screens = []
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
    Node(allScreens: screens, truncateToIndex: truncateToIndex, index: 0)
      .environmentObject(pathHolder)
      .environmentObject(destinationBuilder)
  }

  func truncateToIndex(_ index: Int) {
    screens = Array(screens.prefix(index))
  }

  @ViewBuilder
  private var unwrappedBody: some View {
    /// NOTE: On iOS 14.4 and below, a bug prevented multiple sheet/fullScreenCover modifiers being chained
    /// on the same view, so we conditionally add the sheet/cover modifiers as a workaround. See
    /// https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-14_5-release-notes
    if #available(iOS 14.5, *) {
      rootView
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
      rootView
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
    if withNavigation {
      NavigationView {
        unwrappedBody
      }
      .navigationViewStyle(supportedNavigationViewStyle)
    } else {
      unwrappedBody
    }
  }
}
