import Foundation
import SwiftUI

/// An object that publishes changes to the routes array it holds.
@MainActor
class RoutesHolder: ObservableObject {
  var task: Task<Void, Never>?
  var usingNavigationStack = false

  @Published var routes: [Route<AnyHashable>] = [] {
    didSet {
      guard routes != oldValue else { return }

      let didUpdateSynchronously = synchronouslyUpdateIfSupported(to: routes)
      guard !didUpdateSynchronously else { return }

      task?.cancel()
      task = Task { @MainActor in
        await updateRoutesWithDelays(to: routes)
      }
    }
  }

  @Published var delayedRoutes: [Route<AnyHashable>] = []

  var boundRoutes: [Route<AnyHashable>] {
    get {
      delayedRoutes
    }
    set {
      routes = newValue
    }
  }

  func synchronouslyUpdateIfSupported(to newRoutes: [Route<AnyHashable>]) -> Bool {
    guard FlowPath.canSynchronouslyUpdate(from: delayedRoutes, to: newRoutes, allowNavigationUpdatesInOne: usingNavigationStack) else {
      return false
    }
    delayedRoutes = newRoutes
    return true
  }

  func updateRoutesWithDelays(to newRoutes: [Route<AnyHashable>]) async {
    let steps = FlowPath.calculateSteps(from: delayedRoutes, to: newRoutes, allowNavigationUpdatesInOne: usingNavigationStack)

    delayedRoutes = steps.first!
    await scheduleRemainingSteps(steps: Array(steps.dropFirst()))
  }

  func scheduleRemainingSteps(steps: [[Route<AnyHashable>]]) async {
    guard let firstStep = steps.first else {
      return
    }
    delayedRoutes = firstStep
    do {
      try await Task.sleep(nanoseconds: UInt64(0.65 * 1_000_000_000))
      try Task.checkCancellation()
      await scheduleRemainingSteps(steps: Array(steps.dropFirst()))
    } catch {}
  }
}
