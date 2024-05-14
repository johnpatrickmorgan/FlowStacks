import Foundation
import SwiftUI

/// An object that publishes changes to the routes array it holds.
class RoutesHolder: ObservableObject {
  @Published var routes: [Route<AnyHashable>] = []
}
