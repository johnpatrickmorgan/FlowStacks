import SwiftUI

extension FlowNavigator: RandomAccessCollection {
  public typealias Element = Array<Route<Screen>>.Element
  public typealias Index = Array<Route<Screen>>.Index
  public typealias Indices = Array<Route<Screen>>.Indices
  public typealias SubSequence = Array<Route<Screen>>.SubSequence
  
  public subscript(position: Index) -> Element {
    path[position]
  }

  public subscript(bounds: Range<Index>) -> SubSequence {
    path[bounds]
  }
  
  public var indices: Indices {
    path.indices
  }
  
  public func index(after i: Int) -> Int {
    path.index(after: i)
  }
  
  public var startIndex: Int {
    path.startIndex
  }
  
  public var endIndex: Int {
    path.endIndex
  }
  
  public func _append(element: Element) {
    path.append(element)
  }
  
  public func removeLast(_ count: Int) {
    path.removeLast(count)
  }
  
  public convenience init() {
    var elements: [Element] = []
    self.init(Binding(get: { elements }, set: { elements = $0 }))
  }
  
  public func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with collection: C) where C.Element == Element {
    path.replaceSubrange(subrange, with: collection)
  }
}
