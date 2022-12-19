import Foundation
import SwiftUI

class PathHolder: ObservableObject {
  var path: Binding<[Route<Any>]>

  init(_ path: Binding<[Route<Any>]>) {
    self.path = path
  }
}
