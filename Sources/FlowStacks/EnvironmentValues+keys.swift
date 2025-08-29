import SwiftUI

public enum UseNavigationStackPolicy {
  case whenAvailable
  case never
}

struct UseNavigationStackPolicyKey: EnvironmentKey {
  static var defaultValue: UseNavigationStackPolicy {
    if #available(iOS 26.0, *, macOS 26.0, *, watchOS 26.0, *, tvOS 26.0, *) {
      // NavigationView has problems on iOS 26.
      // See https://github.com/johnpatrickmorgan/TCACoordinators/issues/90
      .whenAvailable
    } else {
      .never
    }
  }
}

enum ParentNavigationStackType {
  case navigationView, navigationStack
}

struct ParentNavigationStackKey: EnvironmentKey {
  static let defaultValue: ParentNavigationStackType? = nil
}

enum FlowStackDataType {
  case typedArray, flowPath, noBinding
}

struct FlowStackDataTypeKey: EnvironmentKey {
  static let defaultValue: FlowStackDataType? = nil
}

extension EnvironmentValues {
  var useNavigationStack: UseNavigationStackPolicy {
    get { self[UseNavigationStackPolicyKey.self] }
    set { self[UseNavigationStackPolicyKey.self] = newValue }
  }

  var parentNavigationStackType: ParentNavigationStackType? {
    get { self[ParentNavigationStackKey.self] }
    set { self[ParentNavigationStackKey.self] = newValue }
  }

  var flowStackDataType: FlowStackDataType? {
    get { self[FlowStackDataTypeKey.self] }
    set { self[FlowStackDataTypeKey.self] = newValue }
  }
}

struct RouteStyleKey: EnvironmentKey {
  static let defaultValue: RouteStyle? = nil
}

public extension EnvironmentValues {
  /// If the view is part of a route within a FlowStack, this denotes the presentation style of the route within the stack.
  internal(set) var routeStyle: RouteStyle? {
    get { self[RouteStyleKey.self] }
    set { self[RouteStyleKey.self] = newValue }
  }
}

struct RouteIndexKey: EnvironmentKey {
  static let defaultValue: Int? = nil
}

public extension EnvironmentValues {
  /// If the view is part of a route within a FlowStack, this denotes the index of the route within the stack.
  internal(set) var routeIndex: Int? {
    get { self[RouteIndexKey.self] }
    set { self[RouteIndexKey.self] = newValue }
  }
}

struct NestingIndexKey: EnvironmentKey {
  static let defaultValue: Int? = nil
}

public extension EnvironmentValues {
  /// If the view is part of a route within a FlowStack, this denotes the number of nested FlowStacks above this view in the hierarchy.
  internal(set) var nestingIndex: Int? {
    get { self[NestingIndexKey.self] }
    set { self[NestingIndexKey.self] = newValue }
  }
}
