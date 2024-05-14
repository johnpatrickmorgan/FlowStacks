import SwiftUI

public enum UseNavigationStackPolicy {
  case whenAvailable
  case never
}

struct UseNavigationStackPolicyKey: EnvironmentKey {
  static let defaultValue = UseNavigationStackPolicy.never
}

struct IsWithinNavigationStackKey: EnvironmentKey {
  static let defaultValue = false
}

enum FlowStackDataType {
  case typedArray, flowPath
}

struct FlowStackDataTypeKey: EnvironmentKey {
  static let defaultValue: FlowStackDataType? = nil
}

extension EnvironmentValues {
  var useNavigationStack: UseNavigationStackPolicy {
    get { self[UseNavigationStackPolicyKey.self] }
    set { self[UseNavigationStackPolicyKey.self] = newValue }
  }

  var isWithinNavigationStack: Bool {
    get { self[IsWithinNavigationStackKey.self] }
    set { self[IsWithinNavigationStackKey.self] = newValue }
  }

  var flowStackDataType: FlowStackDataType? {
    get { self[FlowStackDataTypeKey.self] }
    set { self[FlowStackDataTypeKey.self] = newValue }
  }
}
