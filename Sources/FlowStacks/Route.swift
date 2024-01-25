import Foundation

/// A step in the navigation flow of an app, encompassing a Screen and how it should be shown,
/// e.g. via a push navigation, a sheet or a full-screen cover.
public enum Route<Screen> {
  /// A push navigation. Only valid if the most recently presented screen is embedded in a `NavigationView`.
  /// - Parameter screen: the screen to be shown.
  case push(Screen)
  
  /// A sheet presentation.
  /// - Parameter screen: the screen to be shown.
  /// - Parameter embedInNavigationView: whether the presented screen should be embedded in a `NavigationView`.
  /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
  case sheet(Screen, embedInNavigationView: Bool, onDismiss: (() -> Void)? = nil)
  
  /// A full-screen cover presentation.
  /// - Parameter screen: the screen to be shown.
  /// - Parameter embedInNavigationView: whether the presented screen should be embedded in a `NavigationView`.
  /// - Parameter onDismiss: A closure to be invoked when the screen is dismissed.
  @available(OSX, unavailable, message: "Not available on OS X.")
  case cover(Screen, embedInNavigationView: Bool, onDismiss: (() -> Void)? = nil)
  
  /// The root of the stack. The presentation style is irrelevant as it will not be presented.
  /// - Parameter screen: the screen to be shown.
  public static func root(_ screen: Screen, embedInNavigationView: Bool = false) -> Route {
    return .sheet(screen, embedInNavigationView: embedInNavigationView, onDismiss: nil)
  }
  
  /// The screen to be shown.
  public var screen: Screen {
    get {
      switch self {
      case .push(let screen), .sheet(let screen, _, _), .cover(let screen, _, _):
        return screen
      }
    }
    set {
      switch self {
      case .push:
        self = .push(newValue)
      case .sheet(_, let embedInNavigationView, let onDismiss):
        self = .sheet(newValue, embedInNavigationView: embedInNavigationView, onDismiss: onDismiss)
        #if os(macOS)
        #else
        case .cover(_, let embedInNavigationView, let onDismiss):
          self = .cover(newValue, embedInNavigationView: embedInNavigationView, onDismiss: onDismiss)
      #endif
      }
    }
  }
  
  /// Whether the presented screen should be embedded in a `NavigationView`.
  public var embedInNavigationView: Bool {
    switch self {
    case .push:
      return false
    case .sheet(_, let embedInNavigationView, _), .cover(_, let embedInNavigationView, _):
      return embedInNavigationView
    }
  }
  
  /// The onDIsmiss closure to be called when a sheet or full-screen cover is dismissed.
  public var onDismiss: (() -> Void)? {
    switch self {
    case .push:
      return nil
    case .sheet(_, _, let onDismiss), .cover(_, _, let onDismiss):
      return onDismiss
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
  
  public func map<NewScreen>(_ transform: (Screen) -> NewScreen) -> Route<NewScreen> {
    switch self {
    case .push:
      return .push(transform(screen))
    case .sheet(_, let embedInNavigationView, let onDismiss):
      return .sheet(transform(screen), embedInNavigationView: embedInNavigationView, onDismiss: onDismiss)
#if os(macOS)
#else
    case .cover(_, let embedInNavigationView, let onDismiss):
      return .cover(transform(screen), embedInNavigationView: embedInNavigationView, onDismiss: onDismiss)
#endif
    }
  }
}

extension Route: Equatable where Screen: Equatable {
  /// Compares two Routes for equality, based on screen equality and equality of presentation styles.
  /// Note that any `onDismiss` closures are ignored when checking for equality.
  /// - Returns: A Bool indicating if the two are equal.
  public static func == (lhs: Route, rhs: Route) -> Bool {
    return lhs.style == rhs.style && lhs.screen == rhs.screen
  }
}
