import Foundation
import FlowStacks

enum ProcessArguments {
  static var navigationStackPolicy: UseNavigationStackPolicy {
    // Allows the policy to be set from UI tests.
    ProcessInfo.processInfo.arguments.contains("USE_NAVIGATIONSTACK") ? .whenAvailable : .never
  }
}
