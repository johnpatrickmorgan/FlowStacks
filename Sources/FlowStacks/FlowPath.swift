import Foundation
import SwiftUI

/// A type-erased wrapper for an Array of any Hashable types, to be displayed in a `FlowStack`.
public struct FlowPath: Equatable {
  /// The routes array for the FlowPath.
  public var routes: [Route<AnyHashable>]

  /// The number of routes in the path.
  public var count: Int { routes.count }

  /// Whether the path is empty.
  public var isEmpty: Bool { routes.isEmpty }

  public init(_ routes: [Route<AnyHashable>] = []) {
    self.routes = routes
  }

  public init<S: Sequence, E: Hashable>(_ routes: S) where S.Element == Route<E> {
    self.init(routes.map { $0.map { $0 as AnyHashable } })
  }

  public mutating func append<V: Hashable>(_ value: Route<V>) {
    routes.append(value.erased())
  }

  public mutating func removeLast(_ k: Int = 1) {
    routes.removeLast(k)
  }
}
