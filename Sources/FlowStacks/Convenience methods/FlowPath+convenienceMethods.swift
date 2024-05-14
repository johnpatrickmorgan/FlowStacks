import Foundation

public extension FlowPath {
  /// Pushes a new screen via a push navigation.
  /// - Parameter screen: The screen to push.
  mutating func push(_ screen: AnyHashable) {
    routes.push(screen)
  }

  /// Pops a given number of screens off the stack.
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  mutating func pop(_ count: Int = 1) {
    routes.pop(count)
  }

  /// Pops to a given index in the array of screens. The resulting screen count
  /// will be index.
  /// - Parameter index: The index that should become top of the stack.
  mutating func popTo(index: Int) {
    routes.popTo(index: index)
  }

  /// Pops to the root screen (index 0). The resulting screen count
  /// will be 1.
  mutating func popToRoot() {
    routes.popToRoot()
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the routes array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func popTo(where condition: (AnyHashable) -> Bool) -> Bool {
    routes.popTo(where: { condition($0.screen) })
  }
}

public extension FlowPath {
  /// Pops to the topmost (most recently pushed) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the routes array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo(_ screen: AnyHashable) -> Bool {
    return routes.popTo(screen)
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the routes array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo<T: Hashable>(_: T.Type) -> Bool {
    return popTo(where: { $0 is T })
  }
}
