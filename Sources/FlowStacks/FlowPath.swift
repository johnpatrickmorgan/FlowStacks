import Foundation
import SwiftUI

/// A type-erased wrapper for an Array of any Hashable types, to be displayed in a ``FlowStack``.
public struct FlowPath: Equatable {
  /// The routes array for the FlowPath.
  public var routes: [Route<AnyHashable>]

  /// The number of routes in the path.
  public var count: Int { routes.count }

  /// Whether the path is empty.
  public var isEmpty: Bool { routes.isEmpty }

  /// Creates a ``FlowPath`` with an initial array of routes.
  /// - Parameter routes: The routes for the ``FlowPath``.
  public init(_ routes: [Route<AnyHashable>] = []) {
    self.routes = routes
  }

  /// Creates a ``FlowPath`` with an initial sequence of routes.
  /// - Parameter routes: The routes for the ``FlowPath``.
  public init(_ routes: some Sequence<Route<some Hashable>>) {
    self.init(routes.map { $0.map { $0 as AnyHashable } })
  }

  public mutating func append(_ value: Route<some Hashable>) {
    routes.append(value.erased())
  }

  public mutating func removeLast(_ k: Int = 1) {
    routes.removeLast(k)
  }
}
