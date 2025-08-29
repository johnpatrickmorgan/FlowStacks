import Foundation

public extension FlowPath {
  /// Whether the FlowPath is able to push new screens. If it is not possible to determine,
  /// `nil` will be returned, e.g. if there is no `NavigationView` in this routes stack but it's possible
  /// a `NavigationView` has been added outside the FlowStack..
  var canPush: Bool? {
    routes.canPush
  }

  /// Pushes a new screen via a push navigation.
  /// This should only be called if the most recently presented screen is embedded in a `NavigationView`.
  /// - Parameter screen: The screen to push.
  mutating func push(_ screen: AnyHashable) {
    routes.push(screen)
  }

  /// Presents a new screen via a sheet presentation.
  /// - Parameter screen: The screen to push.
  mutating func presentSheet(_ screen: AnyHashable, withNavigation: Bool = false) {
    routes.presentSheet(screen, withNavigation: withNavigation)
  }

  #if os(macOS)
  #else
    /// Presents a new screen via a full-screen cover presentation.
    /// - Parameter screen: The screen to push.
    @available(OSX, unavailable, message: "Not available on OS X.")
    mutating func presentCover(_ screen: AnyHashable, withNavigation: Bool = false) {
      routes.presentCover(screen, withNavigation: withNavigation)
    }
  #endif
}

// MARK: - Go back

public extension FlowPath {
  /// Returns true if it's possible to go back the given number of screens.
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  func canGoBack(_: Int = 1) -> Bool {
    routes.canGoBack()
  }

  /// Goes back a given number of screens off the stack
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  mutating func goBack(_ count: Int = 1) {
    routes.goBack(count)
  }

  /// Goes back to a given index in the array of screens. The resulting screen count
  /// will be index + 1.
  /// - Parameter index: The index that should become top of the stack.
  mutating func goBackTo(index: Int) {
    routes.goBackTo(index: index)
  }

  /// Goes back to the root screen (index -1). The resulting screen count
  /// will be 0.
  mutating func goBackToRoot() {
    routes.goBackToRoot()
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the routes array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func goBackTo(where condition: (Route<AnyHashable>) -> Bool) -> Bool {
    routes.goBackTo(where: condition)
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the routes array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func goBackTo(where condition: (AnyHashable) -> Bool) -> Bool {
    routes.goBackTo(where: condition)
  }
}

public extension FlowPath {
  /// Goes back to the topmost (most recently shown) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the routes array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func goBackTo(_ screen: AnyHashable) -> Bool {
    routes.goBackTo(screen)
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// whose type matches the given type. If no screens satisfy the condition,
  /// the routes array will be unchanged.
  /// - Parameter type: The type of the screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func goBackTo<T: Hashable>(type _: T.Type) -> Bool {
    goBackTo(where: { $0.screen is T })
  }
}

// MARK: - Pop

public extension FlowPath {
  /// Pops a given number of screens off the stack. Only screens that have been pushed will
  /// be popped.
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  mutating func pop(_ count: Int = 1) {
    routes.pop(count)
  }

  /// Pops to a given index in the array of screens. The resulting screen count
  /// will be index + 1. Only screens that have been pushed will
  /// be popped.
  /// - Parameter index: The index that should become top of the stack.
  mutating func popTo(index: Int) {
    routes.popTo(index: index)
  }

  /// Pops to the root screen (index -1). The resulting screen count
  /// will be 0. Only screens that have been pushed will
  /// be popped.
  mutating func popToRoot() {
    routes.popToRoot()
  }

  /// Pops all screens in the current navigation stack only, without dismissing any screens.
  mutating func popToCurrentNavigationRoot() {
    routes.popToCurrentNavigationRoot()
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the routes array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func popTo(where condition: (Route<AnyHashable>) -> Bool) -> Bool {
    routes.popTo(where: condition)
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the routes array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func popTo(where condition: (AnyHashable) -> Bool) -> Bool {
    routes.popTo(where: condition)
  }
}

public extension FlowPath {
  /// Pops to the topmost (most recently pushed) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the routes array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo(_ screen: AnyHashable) -> Bool {
    routes.popTo(screen)
  }
  
  /// Pops to the topmost (most recently shown) screen in the stack
  /// whose type matches the given type. If no screens satisfy the condition,
  /// the routes array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter type: The type of the screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func popTo<T: Hashable>(type: T.Type) -> Bool {
    popTo(where: { $0.screen is T })
  }
}

// MARK: - Dismiss

public extension FlowPath {
  /// Dismisses a given number of presentation layers off the stack. Only screens that have been presented will
  /// be included in the count.
  /// - Parameter count: The number of presentation layers to go back. Defaults to 1.
  mutating func dismiss(count: Int = 1) {
    routes.dismiss(count: count)
  }

  /// Dismisses all presented sheets and modals, without popping any pushed screens in the bottommost
  /// presentation layer.
  mutating func dismissAll() {
    routes.dismissAll()
  }
}
