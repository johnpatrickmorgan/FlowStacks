import Foundation
import SwiftUI

/// Keeps hold of the destination builder closures for a given type or local destination ID.
class DestinationBuilderHolder: ObservableObject {
  static func identifier(for type: Any.Type) -> String {
    String(reflecting: type)
  }

  var builders: [String: (Binding<AnyHashable>) -> AnyView?] = [:]

  init() {
    builders = [:]
  }

  func appendBuilder<T: Hashable>(_ builder: @escaping (Binding<T>) -> AnyView) {
    let key = Self.identifier(for: T.self)
    builders[key] = { data in
      let binding = Binding(
        get: { data.wrappedValue as! T },
        set: { newValue, transaction in
          data.transaction(transaction).wrappedValue = newValue
        }
      )
      return builder(binding)
    }
  }

  func appendLocalBuilder(identifier: LocalDestinationID, _ builder: @escaping () -> AnyView) {
    let key = identifier.rawValue.uuidString
    builders[key] = { _ in builder() }
  }

  func removeLocalBuilder(identifier: LocalDestinationID) {
    let key = identifier.rawValue.uuidString
    builders[key] = nil
  }

  func build(_ binding: Binding<AnyHashable>) -> AnyView {
    var base = binding.wrappedValue.base
    var key = Self.identifier(for: type(of: base))
    // NOTE: - `wrappedValue` might be nested `AnyHashable` e.g. `AnyHashable<AnyHashable<AnyHashable<MyScreen>>>`.
    // And `base as? AnyHashable` will always produce a `AnyHashable` so we need check if key contains 'AnyHashable' to break the looping.
    while key.contains("AnyHashable"), let anyHashable = base as? AnyHashable {
      base = anyHashable.base
      key = Self.identifier(for: type(of: base))
    }
    if let identifier = base as? LocalDestinationID {
      let key = identifier.rawValue.uuidString
      if let builder = builders[key], let output = builder(binding) {
        return output
      }
      assertionFailure("No view builder found for type \(key)")
    } else {
      let key = Self.identifier(for: type(of: base))

      if let builder = builders[key], let output = builder(binding) {
        return output
      }
      var possibleMirror: Mirror? = Mirror(reflecting: base)
      while let mirror = possibleMirror {
        let mirrorKey = Self.identifier(for: mirror.subjectType)

        if let builder = builders[mirrorKey], let output = builder(binding) {
          return output
        }
        possibleMirror = mirror.superclassMirror
      }
      assertionFailure("No view builder found for type \(type(of: base))")
    }
    return AnyView(Image(systemName: "exclamationmark.triangle"))
  }
}
