import Foundation

public extension RoutableCollection where Element: RouteProtocol {
  /// Whether the Array of Routes is able to push new screens. If it is not possible to determine,
  /// `nil` will be returned, e.g. if there is no `NavigationView` in this routes stack but it's possible
  /// it has been pushed onto a parent coordinator with a `NavigationView`.
  var canPush: Bool? {
    for (index, route) in zip(indices, self).reversed() {
      switch route.style {
      case .push:
        continue
      case .cover(let embedInNavigationView), .sheet(let embedInNavigationView):
        if index > 0 {
          return embedInNavigationView
        } else {
          // Once we reach the root screen, it's not possible to determine if the routes are being pushed onto a
          // parent coordinator with a NavigationView, so we return nil rather than false.
          return embedInNavigationView ? true : nil
        }
      }
    }
    return nil
  }

  /// Pushes a new screen via a push navigation.
  /// This should only be called if the most recently presented screen is embedded in a `NavigationView`.
  /// - Parameter screen: The screen to push.
  mutating func push(_ screen: Element.Screen) {
    assert(
      canPush != false,
      """
      Attempting to push a screen, but the most recently presented screen is not
      embedded in a `NavigationView`. Please ensure the root or most recently presented
      route has `embedInNavigationView` set to `true`.
      """
    )
    _append(element: .push(screen))
  }

  /// Presents a new screen via a sheet presentation.
  /// - Parameter screen: The screen to push.
  /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
  mutating func presentSheet(_ screen: Element.Screen, embedInNavigationView: Bool = false, onDismiss: (() -> Void)? = nil) {
    _append(element: .sheet(screen, embedInNavigationView: embedInNavigationView, onDismiss: onDismiss))
  }

  #if os(macOS)
  #else
  /// Presents a new screen via a full-screen cover presentation.
  /// - Parameter screen: The screen to push.
  /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed. 
  @available(OSX, unavailable, message: "Not available on OS X.")
  mutating func presentCover(_ screen: Element.Screen, embedInNavigationView: Bool = false, onDismiss: (() -> Void)? = nil) {
    _append(element: .cover(screen, embedInNavigationView: embedInNavigationView, onDismiss: onDismiss))
  }
  #endif
}

// MARK: - Go back

public extension RoutableCollection where Element: RouteProtocol {
  /// Goes back a given number of screens off the stack
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  mutating func goBack(_ count: Int = 1) {
    assert(
      self.count - count >= 0,
      "Can't go back\(count == 1 ? "" : " \(count) screens") - the screen count is \(self.count)"
    )
    assert(
      count >= 0,
      "Can't go back \(count) screens - count must be positive"
    )
    guard self.count - count >= 0, count >= 0 else { return }
    removeLast(count)
  }

  /// Goes back to a given index in the array of screens. The resulting screen count
  /// will be index + 1.
  /// - Parameter index: The index that should become top of the stack.
  mutating func goBackTo(index: Int) {
    goBack(endIndex - 1 - index)
  }

  /// Goes back to the root screen (index 0). The resulting screen count
  /// will be 1.
  mutating func goBackToRoot() {
    guard self.count > 1 else { return }
    goBackTo(index: 0)
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func goBackTo(where condition: (Element) -> Bool) -> Bool {
    guard let index = lastIndex(where: condition) else {
      return false
    }
    goBackTo(index: index)
    return true
  }

  /// Goes back to the topmost (most recently shown) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged.
  /// - Parameter condition: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func goBackTo(where condition: (Element.Screen) -> Bool) -> Bool {
    return goBackTo(where: { condition($0.screen) })
  }
}

public extension RoutableCollection where Element: RouteProtocol, Element.Screen: Equatable {
  /// Goes back to the topmost (most recently shown) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func goBackTo(_ screen: Element.Screen) -> Bool {
    goBackTo(where: { $0.screen == screen })
  }
}

public extension RoutableCollection where Element: RouteProtocol, Element.Screen: Identifiable {
  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func goBackTo(id: Element.Screen.ID) -> Bool {
    goBackTo(where: { $0.screen.id == id })
  }

  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func goBackTo(_ screen: Element.Screen) -> Bool {
    goBackTo(id: screen.id)
  }
}

/// Avoids an ambiguity when `Screen` is both `Identifiable` and `Equatable`.
public extension RoutableCollection where Element: RouteProtocol, Element.Screen: Identifiable & Equatable {
  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func goBackTo(_ screen: Element.Screen) -> Bool {
    goBackTo(id: screen.id)
  }
}

// MARK: - Pop

public extension RoutableCollection where Element: RouteProtocol {
  /// Pops a given number of screens off the stack. Only screens that have been pushed will
  /// be popped.
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  mutating func pop(_ count: Int = 1) {
    assert(count <= self.count)
    assert(suffix(count).allSatisfy { $0.style == .push })
    goBack(count)
  }

  /// Pops to a given index in the array of screens. The resulting screen count
  /// will be index + 1. Only screens that have been pushed will
  /// be popped.
  /// - Parameter index: The index that should become top of the stack.
  mutating func popTo(index: Int) {
    let popCount = count - (index + 1)
    pop(popCount)
  }

  /// Pops to the root screen (index 0). The resulting screen count
  /// will be 1. Only screens that have been pushed will
  /// be popped.
  mutating func popToRoot() {
    popTo(index: 0)
  }
  
  /// Pops all screens in the current navigation stack only, without dismissing any screens.
  mutating func popToCurrentNavigationRoot() {
    var index = endIndex - 1
    while indices.contains(index), !self[index].isPresented, index > 0 {
      index -= 1
    }
    goBackTo(index: index)
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func popTo(where condition: (Element) -> Bool) -> Bool {
    guard let index = lastIndex(where: condition) else {
      return false
    }
    popTo(index: index)
    return true
  }

  /// Pops to the topmost (most recently pushed) screen in the stack
  /// that satisfies the given condition. If no screens satisfy the condition,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter condition: The predicate indicating which screen to pop to.
  /// - Returns: A `Bool` indicating whether a screen was found.
  @discardableResult
  mutating func popTo(where condition: (Element.Screen) -> Bool) -> Bool {
    return popTo(where: { condition($0.screen) })
  }
}

public extension RoutableCollection where Element: RouteProtocol, Element.Screen: Equatable {
  /// Pops to the topmost (most recently pushed) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo(_ screen: Element.Screen) -> Bool {
    popTo(where: { $0 == screen })
  }
}

public extension RoutableCollection where Element: RouteProtocol, Element.Screen: Identifiable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// Only screens that have been pushed will
  /// be popped.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo(id: Element.Screen.ID) -> Bool {
    popTo(where: { $0.id == id })
  }

  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo(_ screen: Element.Screen) -> Bool {
    popTo(id: screen.id)
  }
}

/// Avoids an ambiguity when `Screen` is both `Identifiable` and `Equatable`.
public extension RoutableCollection where Element: RouteProtocol, Element.Screen: Identifiable & Equatable {
  /// Pops to the topmost (most recently pushed) identifiable screen in the stack
  /// matching the given screen. If no screens are found, the screens array
  /// will be unchanged. Only screens that have been pushed will
  /// be popped.
  /// - Parameter screen: The screen to pop to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func popTo(_ screen: Element.Screen) -> Bool {
    popTo(id: screen.id)
  }
}

// MARK: - Dismiss

public extension RoutableCollection where Element: RouteProtocol {
  /// Dismisses a given number of presentation layers off the stack. Only screens that have been presented will
  /// be included in the count.
  /// - Parameter count: The number of presentation layers to go back. Defaults to 1.
  mutating func dismiss(count: Int = 1) {
    assert(count >= 0)
    var index = endIndex - 1
    var dismissed = 0
    while dismissed < count, indices.contains(index) {
      assert(
        index > 0,
        "Can't dismiss\(count == 1 ? "" : " \(count) screens") - the number of presented screens is \(dismissed)"
      )
      guard index > 0 else { return }
      
      if self[index].isPresented {
        dismissed += 1
      }
      index -= 1
    }
    goBackTo(index: index)
  }
  
  /// Dismisses all presented sheets and modals, without popping any pushed screens in the bottommost
  /// presentation layer.
  mutating func dismissAll() {
    let count = self.dropFirst().filter { $0.isPresented }.count
    guard count > 0 else { return }
    dismiss(count: count)
  }
}
