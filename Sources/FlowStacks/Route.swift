import Foundation

public typealias Routes<T> = [Route<T>]

/// A step in the navigation flow of an app, encompassing a Screen and how it should be shown,
/// e.g. via a push navigation, a sheet or a full-screen cover.
public enum Route<Screen> {
  /// A push navigation. Only valid if the most recently presented screen is embedded in a `NavigationView`.
  /// - Parameter screen: the screen to be shown.
  case push(Screen)

  /// A sheet presentation.
  /// - Parameter screen: the screen to be shown.
  /// - Parameter withNavigation: whether the presented screen should be embedded in a `NavigationView`.
  case sheet(Screen, withNavigation: Bool)

  /// A full-screen cover presentation.
  /// - Parameter screen: the screen to be shown.
  /// - Parameter withNavigation: whether the presented screen should be embedded in a `NavigationView`.
  @available(OSX, unavailable, message: "Not available on OS X.")
  case cover(Screen, withNavigation: Bool)

  /// The screen to be shown.
  public var screen: Screen {
    get {
      switch self {
      case let .push(screen), let .sheet(screen, _), let .cover(screen, _):
        screen
      }
    }
    set {
      switch self {
      case .push:
        self = .push(newValue)
      case let .sheet(_, withNavigation):
        self = .sheet(newValue, withNavigation: withNavigation)
        #if os(macOS)
        #else
          case let .cover(_, withNavigation):
            self = .cover(newValue, withNavigation: withNavigation)
      #endif
      }
    }
  }

  /// Whether the presented screen should be embedded in a `NavigationView`.
  public var withNavigation: Bool {
    switch self {
    case .push:
      false
    case let .sheet(_, withNavigation), let .cover(_, withNavigation):
      withNavigation
    }
  }

  /// Whether the route is presented (via a sheet or cover presentation).
  public var isPresented: Bool {
    switch self {
    case .push:
      false
    case .sheet, .cover:
      true
    }
  }

  /// Transforms the screen data within the route.
  /// - Parameter transform: The transform to be applied.
  /// - Returns: A new route with the same route style, but transformed screen data.
  public func map<NewScreen>(_ transform: (Screen) -> NewScreen) -> Route<NewScreen> {
    switch self {
    case .push:
      return .push(transform(screen))
    case let .sheet(_, withNavigation):
      return .sheet(transform(screen), withNavigation: withNavigation)
      #if os(macOS)
      #else
        case let .cover(_, withNavigation):
          return .cover(transform(screen), withNavigation: withNavigation)
    #endif
    }
  }
}

extension Route: Equatable where Screen: Equatable {}

extension Route: Codable where Screen: Codable {}

extension Route where Screen: Hashable {
  func erased() -> Route<AnyHashable> {
    if let anyHashableSelf = self as? Route<AnyHashable> {
      return anyHashableSelf
    }
    return map { $0 }
  }
}
