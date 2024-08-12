import Foundation
import SwiftUI

/// An object that publishes changes to the routes array it holds.
@MainActor
class RoutesHolder: ObservableObject {
  var task: Task<Void, Never>?
  
  @Published var routes: [Route<AnyHashable>] = [] {
    didSet {
      task?.cancel()
      task = _withDelaysIfUnsupported(\.delayedRoutes, transform: { $0 = routes })
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
