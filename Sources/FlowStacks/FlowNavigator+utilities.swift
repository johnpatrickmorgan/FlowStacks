import Foundation

public extension FlowNavigator {
  /// Whether the Array of Routes is able to push new screens. If it is not possible to determine,
  /// `nil` will be returned, e.g. if there is no `NavigationView` in this routes stack but it's possible
  /// it has been pushed onto a parent coordinator with a `NavigationView`.
  var canPush: Bool? {
    routes.canPush
  }

  /// Pushes a new screen via a push navigation.
  /// This should only be called if the most recently presented screen is embedded in a `NavigationView`.
  /// - Parameter screen: The screen to push.
  func push(_ screen: Screen) {
    routes.push(screen)
  }

  /// Presents a new screen via a sheet presentation.
  /// - Parameter screen: The screen to push.
  /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
  func presentSheet(_ screen: Screen, embedInNavigationView: Bool = false, onDismiss: (() -> Void)? = nil) {
    routes.presentSheet(screen, embedInNavigationView: embedInNavigationView, onDismiss: onDismiss)
  }

  #if os(macOS)
  #else
    /// Presents a new screen via a full-screen cover presentation.
    /// - Parameter screen: The screen to push.
    /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
    @available(OSX, unavailable, message: "Not available on OS X.")
    func presentCover(_ screen: Screen, embedInNavigationView: Bool = false, onDismiss: (() -> Void)? = nil) {
      routes.presentCover(screen, embedInNavigationView: embedInNavigationView, onDismiss: onDismiss)
    }
  #endif
}

// MARK: - Go back

public extension FlowNavigator {
  /// Goes back a given number of screens off the stack
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  func goBack(_ count: Int = 1) {
    routes.goBack(count)
  }

  /// Goes back to a given index in the array of screens. The resulting screen count
  /// will be index + 1.
  /// - Parameter index: The index that should become top of the stack.
  func goBackTo(index: Int) {
    routes.goBackTo(index: index)
  }

  /// Goes back to the root screen (index 0). The resulting screen count
  /// will be 1.
  func goBackToRoot() {
    routes.goBackToRoot()
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func goBackTo(where condition: (Route<Screen>) -> Bool) -> Bool {
    routes.goBackTo(where: condition)
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func goBackTo(where condition: (Screen) -> Bool) -> Bool {
    routes.goBackTo(where: condition)
  }
}

public extension FlowNavigator where Screen: Equatable {
  /// Goes back to the topmost (most recently shown) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func goBackTo(_ screen: Screen) -> Bool {
    routes.goBackTo(screen)
  }
}

public extension FlowNavigator where Screen: Identifiable {
  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func goBackTo(id: Screen.ID) -> Bool {
    routes.goBackTo(id: id)
  }

  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func goBackTo(_ screen: Screen) -> Bool {
    routes.goBackTo(screen)
  }
}

/// Avoids an ambiguity when `Screen` is both `Identifiable` and `Equatable`.
public extension FlowNavigator where Screen: Identifiable & Equatable {
  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func goBackTo(_ screen: Screen) -> Bool {
    routes.goBackTo(screen)
  }
}

// MARK: - Pop

public extension FlowNavigator {
  /// Pops a given number of screens off the stack. Only screens that have been pushed will
  /// be popped.
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  func pop(_ count: Int = 1) {
    routes.pop(count)
  }

  /// Pops to a given index in the array of screens. The resulting screen count
  /// will be index + 1. Only screens that have been pushed will
  /// be popped.
  /// - Parameter index: The index that should become top of the stack.
  func popTo(index: Int) {
    routes.popTo(index: index)
  }

  /// Pops to the root screen (index 0). The resulting screen count
  /// will be 1. Only screens that have been pushed will
  /// be popped.
  func popToRoot() {
    routes.popToRoot()
  }

  /// Pops all screens in the current navigation stack only, without dismissing any screens.
  func popToCurrentNavigationRoot() {
    routes.popToCurrentNavigationRoot()
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func popTo(where condition: (Route<Screen>) -> Bool) -> Bool {
    routes.popTo(where: condition)
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  func popTo(where condition: (Screen) -> Bool) -> Bool {
    routes.popTo(where: condition)
  }
}

public extension FlowNavigator where Screen: Equatable {
  /// Pops to the topmost (most recently pushed) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(_ screen: Screen) -> Bool {
    routes.popTo(screen)
  }
}

public extension FlowNavigator where Screen: Identifiable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// Only screens that have been pushed will
  /// be popped.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(id: Screen.ID) -> Bool {
    routes.popTo(id: id)
  }

  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(_ screen: Screen) -> Bool {
    routes.popTo(screen)
  }
}

/// Avoids an ambiguity when `Screen` is both `Identifiable` and `Equatable`.
public extension FlowNavigator where Screen: Identifiable & Equatable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The screen to pop to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  func popTo(_ screen: Screen) -> Bool {
    routes.popTo(screen)
  }
}

// MARK: - Dismiss

public extension FlowNavigator {
  /// Dismisses a given number of presentation layers off the stack. Only screens that have been presented will
  /// be included in the count.
  /// - Parameter count: The number of presentation layers to go back. Defaults to 1.
  func dismiss(count: Int = 1) {
    routes.dismiss(count: count)
  }

  /// Dismisses all presented sheets and modals, without popping any pushed screens in the bottommost
  /// presentation layer.
  func dismissAll() {
    routes.dismissAll()
  }
}
