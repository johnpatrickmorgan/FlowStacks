import Foundation

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
  
  public static func sheet(_ screen: Screen) -> Route {
    return .sheet(screen, withNavigation: false)
  }
  
  public static func cover(_ screen: Screen) -> Route {
    return .cover(screen, withNavigation: false)
  }
  
  /// The screen to be shown.
  public var screen: Screen {
    get {
      switch self {
      case .push(let screen), .sheet(let screen, _), .cover(let screen, _):
        return screen
      }
    }
    set {
      switch self {
      case .push:
        self = .push(newValue)
      case .sheet(_, let withNavigation):
        self = .sheet(newValue, withNavigation: withNavigation)
        #if os(macOS)
        #else
        case .cover(_, let withNavigation):
          self = .cover(newValue, withNavigation: withNavigation)
      #endif
      }
    }
  }
  
  /// Whether the presented screen should be embedded in a `NavigationView`.
  public var withNavigation: Bool {
    switch self {
    case .push:
      return false
    case .sheet(_, let withNavigation), .cover(_, let withNavigation):
      return withNavigation
    }
  }
  
  /// Whether the route is presented (via a sheet or cover presentation).
  public var isPresented: Bool {
    switch self {
    case .push:
      return false
    case .sheet, .cover:
      return true
    }
  }
  
  /// Whether the route is pushed, presented as a sheet or presented as a full-screen
  /// cover.
  public var style: RouteStyle {
    switch self {
    case .push:
      return .push
    case .sheet(_, let withNavigation):
      return .sheet(withNavigation: withNavigation)
    case .cover(_, let withNavigation):
      return .cover(withNavigation: withNavigation)
    }
  }
  
  public init(screen: Screen, style: RouteStyle) {
    switch style {
    case .push:
      self = .push(screen)
    case .sheet(let withNavigation):
      self = .sheet(screen, withNavigation: withNavigation)
    case .cover(let withNavigation):
      self = .cover(screen, withNavigation: withNavigation)
    }
  }
  
  public func map<NewScreen>(_ transform: (Screen) -> NewScreen) -> Route<NewScreen> {
    switch self {
    case .push:
      return .push(transform(screen))
    case .sheet(_, let withNavigation):
      return .sheet(transform(screen), withNavigation: withNavigation)
      #if os(macOS)
      #else
      case .cover(_, let withNavigation):
        return .cover(transform(screen), withNavigation: withNavigation)
    #endif
    }
  }
}

extension Route: Equatable where Screen: Equatable {
  /// Compares two Routes for equality, based on screen equality and equality of presentation styles.
  /// - Returns: A Bool indicating if the two are equal.
  public static func == (lhs: Route, rhs: Route) -> Bool {
    return lhs.style == rhs.style && lhs.screen == rhs.screen
  }
}

extension Route: Hashable where Screen: Hashable {
  public func hash(into hasher: inout Hasher) {
    screen.hash(into: &hasher)
    style.hash(into: &hasher)
  }
}

extension Route: Encodable where Screen: Encodable {}

extension Route: Decodable where Screen: Decodable {}
