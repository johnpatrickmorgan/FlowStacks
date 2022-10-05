/// The style with which a route is shown, i.e., if the route is pushed, presented
/// as a sheet or presented as a full-screen cover.
public enum RouteStyle: Hashable {
  case push, sheet(withNavigation: Bool = false), cover(withNavigation: Bool = false)
  
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
  
  public var withNavigation: Bool {
    switch self {
    case .push:
      return false
    case .sheet(let withNavigation), .cover(let withNavigation):
      return withNavigation
    }
  }
}
