//
//  File.swift
//  
//
//  Created by John Morgan on 16/01/2024.
//

import Foundation
import SwiftUI

struct NewNode<Screen, V: View>: View {
  @Binding var allScreens: [Route<Screen>]
  let buildView: (Binding<Screen>, Int) -> V
  let truncateToIndex: (Int) -> Void
  let index: Int
  let screen: Screen?
  @EnvironmentObject var navigator: FlowNavigator<Screen>

  @State var isAppeared = false

  init(allScreens: Binding<[Route<Screen>]>, truncateToIndex: @escaping (Int) -> Void, index: Int, buildView: @escaping (Binding<Screen>, Int) -> V) {
    _allScreens = allScreens
    self.truncateToIndex = truncateToIndex
    self.index = index
    self.buildView = buildView
    screen = allScreens.wrappedValue[safe: index]?.screen
  }

  private var isActiveBinding: Binding<Bool> {
    return Binding(
      get: { allScreens.count > index + 1 },
      set: { isShowing in
        guard !isShowing else { return }
        guard allScreens.count > index + 1 else { return }
        guard isAppeared else { return }
        truncateToIndex(index + 1)
      }
    )
  }

  var next: some View {
    NewNode(allScreens: $allScreens, truncateToIndex: truncateToIndex, index: index + 1, buildView: buildView)
  }
  
  var nextRouteStyle: RouteStyle? {
    allScreens[safe: index + 1]?.style
  }

  @ViewBuilder
  var content: some View {
    if let screen = allScreens[safe: index]?.screen ?? screen {
      let screenBinding = Binding<Screen>(
        get: { allScreens[safe: index]?.screen ?? screen },
        set: { allScreens[index].screen = $0 }
      )
      buildView(screenBinding, index)
        .pushing(
          isActive: nextRouteStyle == .push ? isActiveBinding : .constant(false),
          destination: next
        )
        .presenting(
          sheetBinding: (nextRouteStyle?.isSheet ?? false) ? isActiveBinding : .constant(false),
          coverBinding: (nextRouteStyle?.isCover ?? false) ? isActiveBinding : .constant(false),
          destination: next
        )
        .onAppear { isAppeared = true }
        .onDisappear { isAppeared = false }
    }
  }
  
  var body: some View {
    let route = allScreens[safe: index]
    if route?.embedInNavigationView ?? false {
      NavigationView {
        content
      }
      .navigationViewStyle(supportedNavigationViewStyle)
    } else {
      content
    }
  }
}


extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
