import Foundation

/// An array of `Route`s.
public typealias Routes<Screen> = [Route<Screen>]

// NOTE: The RoutableCollection abstraction exists so that the methods available on Array are also
// available on other collections, such as IdentifiedArray (from
// https://github.com/pointfreeco/swift-identified-collections). In theory, RoutableCollection could
// simply be RangeReplaceableCollection, but IdentifiedArray does not conform to RangeReplaceableCollection.

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
