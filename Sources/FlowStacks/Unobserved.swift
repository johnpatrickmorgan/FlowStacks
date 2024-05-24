import SwiftUI

/// A wrapper that allows access to an observable object without publishing its changes.
class Unobserved<Object: ObservableObject>: ObservableObject {
  let object: Object

  init(object: Object) {
    self.object = object
  }
}
