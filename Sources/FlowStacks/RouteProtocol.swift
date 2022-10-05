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
  
extension Route: RouteProtocol {}
