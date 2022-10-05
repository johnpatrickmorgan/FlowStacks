import Foundation
import SwiftUI

class DestinationBuilderHolder: ObservableObject {
  static func identifier(for type: Any.Type) -> String {
    String(reflecting: type)
  }

  var builders: [String: (Any, Int, RouteStyle) -> AnyView?] = [:]

  init() {
    builders = [:]
  }

  func appendBuilder<T>(_ builder: @escaping (T, Int, RouteStyle) -> AnyView) {
    let key = Self.identifier(for: T.self)
    builders[key] = { data, index, style in
      guard let typedData = data as? T else {
        return nil
      }
      return builder(typedData, index, style)
    }
  }

  func build<T>(_ data: T, index: Int, style: RouteStyle) -> AnyView {
    let unwrappedData = (data as? AnyHashable)?.base ?? data
    let type = type(of: unwrappedData)
    let key = Self.identifier(for: type)
    if let builder = builders[key], let output = builder(unwrappedData, index, style) {
      return output
    }
    assertionFailure("No view builder found for key \(key)")
    return AnyView(Image(systemName: "exclamationmark.triangle"))
  }
}
