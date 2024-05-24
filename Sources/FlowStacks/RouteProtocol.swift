import Foundation

/// The RouteProtocol is used to restrict the extensions on Array so that they do not
/// pollute autocomplete for Arrays containing other types.
public protocol RouteProtocol {
  associatedtype Screen

  static func push(_ screen: Screen) -> Self
  static func sheet(_ screen: Screen, withNavigation: Bool) -> Self
  #if os(macOS)
  // Full-screen cover unavailable.
  #else
    static func cover(_ screen: Screen, withNavigation: Bool) -> Self
  #endif
  var screen: Screen { get set }
  var withNavigation: Bool { get }
  var isPresented: Bool { get }

  var style: RouteStyle { get }
}

public extension RouteProtocol {
  /// A sheet presentation.
  /// - Parameter screen: the screen to be shown.
  static func sheet(_ screen: Screen) -> Self {
    sheet(screen, withNavigation: false)
  }

  #if os(macOS)
  // Full-screen cover unavailable.
  #else
    /// A full-screen cover presentation.
    /// - Parameter screen: the screen to be shown.
    @available(OSX, unavailable, message: "Not available on OS X.")
    static func cover(_ screen: Screen) -> Self {
      cover(screen, withNavigation: false)
    }
  #endif

  /// The root of the stack. The presentation style is irrelevant as it will not be presented.
  /// - Parameter screen: the screen to be shown.
  static func root(_ screen: Screen, withNavigation: Bool = false) -> Self {
    sheet(screen, withNavigation: withNavigation)
  }
}

extension Route: RouteProtocol {}
