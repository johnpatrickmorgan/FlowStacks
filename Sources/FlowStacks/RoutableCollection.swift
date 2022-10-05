import Foundation

/// An array of `Route`s.
public typealias Routes<Screen> = [Route<Screen>]

/// A collection such as Array that can house a list of Routes. The protocol is extended with a number
/// of utility functions such as `goBack()`.
public protocol RoutableCollection: RandomAccessCollection where Index == Int {
  // Both Array and IdentifiedArray have an append function, but their signatures are different, so
  // a third _append function is used to proxy for both.
  mutating func _append(element: Element)
  mutating func removeLast(_ count: Int)
}

extension Array: RoutableCollection {
  public mutating func _append(element: Element) {
    append(element)
  }
}

extension FlowPath: RoutableCollection {
  public typealias Element = Array<Route<AnyHashable>>.Element
  public typealias Index = Array<Route<AnyHashable>>.Index
  public typealias Indices = Array<Route<AnyHashable>>.Indices
  public typealias SubSequence = Array<Route<AnyHashable>>.SubSequence
  
  public subscript(position: Index) -> Element {
    elements[position]
  }

  public subscript(bounds: Range<Index>) -> SubSequence {
    elements[bounds]
  }
  
  public var indices: Indices {
    elements.indices
  }
  
  public func index(after i: Int) -> Int {
    elements.index(after: i)
  }
  
  public var startIndex: Int {
    elements.startIndex
  }
  
  public var endIndex: Int {
    elements.endIndex
  }
  
  public mutating func _append(element: Element) {
    elements.append(element)
  }
  
  public init() {
    self.init([])
  }
  
  public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Self.Index>, with collection: C) where C.Element == Element {
    elements.replaceSubrange(subrange, with: collection)
  }
}

extension FlowPath: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}
