import Foundation
import SwiftUI

/// An object that publishes changes to the routes array it holds.
@MainActor
class RoutesHolder: ObservableObject {
  var task: Task<Void, Never>?
  var usingNavigationStack = false

  @Published var routes: [Route<AnyHashable>] = [] {
    didSet {
      guard routes != oldValue, !usingNavigationStack else { return }
      // TODO: check if multiple presentations and pushes work.
      // NOTE: We don't need to delay updates if we are using NavigationStack.
      task?.cancel()
      task = Task { @MainActor in
        await _withDelaysIfUnsupported(\.delayedRoutes, transform: { $0 = routes })
      }
    }
  }

  @Published var delayedRoutes: [Route<AnyHashable>] = []

  var boundRoutes: [Route<AnyHashable>] {
    get {
      delayedRoutes
    }
    set {
      routes = newValue
    }
  }
}

extension Array where Element: RouteProtocol {
  subscript(navigationStackFrom initialIndex: Int) -> [Element] {
    get {
      guard !isEmpty, initialIndex < endIndex else { return [] }
      let remainder = self[initialIndex...]
      let finalIndex = remainder.firstIndex(where: { $0.isPresented }) ?? endIndex
      return Array(self[initialIndex ..< finalIndex])
    }
    set {
      // TODO: Handle if change is not on top of stack?
      removeSubrange(initialIndex ..< endIndex)
      append(contentsOf: newValue)
    }
  }
}
