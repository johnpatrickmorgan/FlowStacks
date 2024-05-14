import Foundation
import SwiftUI

extension FlowPath {
  /// Calculates the minimal number of steps to update from one routes array to another, within the constraints of SwiftUI.
  /// For a given update to an array of routes, returns the minimum intermediate steps.
  /// required to ensure each update is supported by SwiftUI.
  /// - Parameters:
  ///   - start: The initial state.
  ///   - end: The goal state.
  /// - Returns: A series of state updates from the start to end.
  public static func calculateSteps<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) -> [[Route<Screen>]] {
    let pairs = Array(zip(start, end))
    let firstDivergingIndex = pairs
      .firstIndex(where: { $0.style != $1.style }) ?? pairs.endIndex
    let firstDivergingPresentationIndex = start[firstDivergingIndex ..< start.count]
      .firstIndex(where: { $0.isPresented }) ?? start.endIndex
    
    // Initial step is to change screen content without changing navigation structure.
    let initialStep = Array(end[..<firstDivergingIndex] + start[firstDivergingIndex...])
    var steps = [initialStep]
    
    // Dismiss extraneous presented stacks.
    while var dismissStep = steps.last, dismissStep.count > firstDivergingPresentationIndex {
      var dismissed: Route<Screen>? = dismissStep.popLast()
      // Ignore pushed screens as they can be dismissed en masse.
      while dismissed?.isPresented == false, dismissStep.count > firstDivergingPresentationIndex {
        dismissed = dismissStep.popLast()
      }
      steps.append(dismissStep)
    }
    
    // Pop extraneous pushed screens.
    while var popStep = steps.last, popStep.count > firstDivergingIndex {
      var popped: Route<Screen>? = popStep.popLast()
      while popped?.style == .push, popStep.count > firstDivergingIndex, popStep.last?.style == .push {
        popped = popStep.popLast()
      }
      steps.append(popStep)
    }
    
    // Push or present each new step.
    while var newStep = steps.last, newStep.count < end.count {
      newStep.append(end[newStep.count])
      steps.append(newStep)
    }
    
    return steps
  }

  static func canSynchronouslyUpdate<Screen>(from start: [Route<Screen>], to end: [Route<Screen>]) -> Bool {
    // If there are less than 3 steps, the transformation can be applied in one update.
    let steps = calculateSteps(from: start, to: end)
    return steps.count < 3
  }
}
