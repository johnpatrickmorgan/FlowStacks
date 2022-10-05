import Foundation
import SwiftUI

// TODO: Make FlowPath a typealias of [Route<AnyHashable>] or [Route<AnyHashable>]

public struct FlowPath {
  var elements: [Route<AnyHashable>]

  public var count: Int { elements.count }
  public var isEmpty: Bool { elements.isEmpty }

  public init(_ elements: [Route<AnyHashable>] = []) {
    self.elements = elements
  }

  public init<S: Sequence>(_ elements: S) where S.Element: Hashable {
    self.init(elements.map(AnyHashable.init))
  }

  public mutating func append<V: Hashable>(_ route: Route<V>) {
    elements.append(route.map { $0 as AnyHashable })
  }

  public mutating func removeLast(_ k: Int = 1) {
    elements.removeLast(k)
  }
}

extension FlowPath: Equatable {}
