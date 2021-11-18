import Foundation

public extension Array where Element: RouteProtocol {
  
  /// Pushes a new screen via a push navigation.
  /// This should only be called if the most recently presented screen is embedded in a `NavigationView`.
  /// - Parameter screen: The screen to push.
  mutating func push(_ screen: Element.Screen) {
    append(.push(screen))
  }
  
  /// Presents a new screen via a sheet presentation.
  /// - Parameter screen: The screen to push.
  mutating func presentSheet(_ screen: Element.Screen, embedInNavigationView: Bool = false) {
    append(.sheet(screen, embedInNavigationView: embedInNavigationView))
  }
  
  /// Presents a new screen via a full-screen cover presentation.
  /// - Parameter screen: The screen to push.
  mutating func presentCover(_ screen: Element.Screen, embedInNavigationView: Bool = false) {
    append(.cover(screen, embedInNavigationView: embedInNavigationView))
  }
  
  /// Goes back a given number of screens off the stack
  /// - Parameter count: The number of screens to go back. Defaults to 1.
  mutating func goBack(count: Int = 1) {
    self = dropLast(count)
  }
  
  /// Goes back to a given index in the array of screens. The resulting screen count
  /// will be index + 1.
  /// - Parameter index: The index that should become top of the stack.
  mutating func goBackTo(index: Int) {
    self = Array(prefix(index + 1))
  }
  
  /// Goes back to the root screen (index 0). The resulting screen count
  /// will be 1.
  mutating func goBackToRoot() {
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

public extension Array where Element: RouteProtocol, Element.Screen: Equatable {
  
  /// Goes back to the topmost (most recently shown) screen in the stack
  /// equal to the given screen. If no screens are found,
  /// the screens array will be unchanged.
  /// - Parameter screen: The predicate indicating which screen to go back to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func goBackTo(_ screen: Element.Screen) -> Bool {
    goBackTo(where: { $0 == screen })
  }
}

public extension Array where Element: RouteProtocol, Element.Screen:  Identifiable {
  
  /// Goes back to the topmost (most recently shown) identifiable screen in the stack
  /// with the given ID. If no screens are found, the screens array will be unchanged.
  /// - Parameter id: The id of the screen to goBack to.
  /// - Returns: A `Bool` indicating whether a matching screen was found.
  @discardableResult
  mutating func goBackTo(id: Element.Screen.ID) -> Bool {
    goBackTo(where: { $0.id == id })
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

/// Avoids an ambiguity for `goBackTo` when `Screen` is both `Identifiable` and `Equatable`.
public extension Array where Element: RouteProtocol, Element.Screen: Identifiable & Equatable {
  
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
