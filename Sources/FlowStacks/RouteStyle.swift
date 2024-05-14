import Foundation

/// The style with which a route is shown, i.e., if the route is pushed, presented
/// as a sheet or presented as a full-screen cover.
public enum RouteStyle: Hashable, Codable {
  case push, sheet(withNavigation: Bool)

  @available(OSX, unavailable, message: "Not available on OS X.")
  case cover(withNavigation: Bool)

  public static var sheet = RouteStyle.sheet(withNavigation: false)

  @available(OSX, unavailable, message: "Not available on OS X.")
  public static var cover = RouteStyle.cover(withNavigation: false)

  public var isSheet: Bool {
    switch self {
    case .sheet:
      return true
    case .cover, .push:
      return false
    }
  }

  public var isCover: Bool {
    switch self {
    case .cover:
      return true
    case .sheet, .push:
      return false
    }
  }

  public var isPush: Bool {
    switch self {
    case .push:
      return true
    case .sheet, .cover:
      return false
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
