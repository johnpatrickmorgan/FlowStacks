import Foundation
import SwiftUI

class PathHolder: ObservableObject {
  var path: Binding<[Route<AnyHashable>]>

  init(_ path: Binding<[Route<AnyHashable>]>) {
    self.path = path
  }
}
