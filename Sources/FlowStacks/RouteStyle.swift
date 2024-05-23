import Foundation

/// The style with which a route is shown, i.e., if the route is pushed, presented
/// as a sheet or presented as a full-screen cover.
public enum RouteStyle: Hashable, Codable {
  /// A push navigation. Only valid if the most recently presented screen is embedded in a `NavigationView`.
  case push

  /// A sheet presentation.
  /// - Parameter withNavigation: whether the presented screen should be embedded in a `NavigationView`.
  case sheet(withNavigation: Bool)

  /// A full-screen cover presentation.
  /// - Parameter withNavigation: whether the presented screen should be embedded in a `NavigationView`.
  @available(OSX, unavailable, message: "Not available on OS X.")
  case cover(withNavigation: Bool)

  /// A sheet presentation.
  public static var sheet = RouteStyle.sheet(withNavigation: false)

  /// A full-screen cover presentation.
  @available(OSX, unavailable, message: "Not available on OS X.")
  public static var cover = RouteStyle.cover(withNavigation: false)

  /// Whether the route style is `sheet`.
  public var isSheet: Bool {
    switch self {
    case .sheet:
      true
    case .cover, .push:
      false
    }
  }

  /// Whether the route style is `cover`.
  public var isCover: Bool {
    switch self {
    case .cover:
      true
    case .sheet, .push:
      false
    }
  }

  /// Whether the route style is `push`.
  public var isPush: Bool {
    switch self {
    case .push:
      true
    case .sheet, .cover:
      false
    }
  }
}

public extension Route {
  /// Whether the route is pushed, presented as a sheet or presented as a full-screen
  /// cover.
  var style: RouteStyle {
    switch self {
    case .push:
      return .push
    case let .sheet(_, withNavigation):
      return .sheet(withNavigation: withNavigation)
      #if os(macOS)
      #else
        case let .cover(_, withNavigation):
          return .cover(withNavigation: withNavigation)
    #endif
    }
  }

  /// Initialises a ``Route`` with the given screen data and route style
  /// - Parameters:
  ///   - screen: The screen data.
  ///   - style: The route style, e.g. `push`.
  init(screen: Screen, style: RouteStyle) {
    switch style {
    case .push:
      self = .push(screen)
    case let .sheet(withNavigation):
      self = .sheet(screen, withNavigation: withNavigation)
      #if os(macOS)
      #else
        case let .cover(withNavigation):
          self = .cover(screen, withNavigation: withNavigation)
    #endif
    }
  }
}
