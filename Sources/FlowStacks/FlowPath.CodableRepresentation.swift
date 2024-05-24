import Foundation

public extension FlowPath {
  /// A codable representation of a FlowPath.
  struct CodableRepresentation {
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()

    var elements: [Route<Codable>]
  }

  var codable: CodableRepresentation? {
    let codableElements = routes.compactMap { route -> Route<Codable>? in
      guard let codableScreen = route.screen as? Codable else {
        return nil
      }
      return Route(screen: codableScreen, style: route.style)
    }
    guard codableElements.count == routes.count else {
      return nil
    }
    return CodableRepresentation(elements: codableElements)
  }

  init(_ codable: CodableRepresentation) {
    // NOTE: Casting to Any first prevents the compiler from flagging the cast to AnyHashable as one that
    // always fails (which it isn't, thanks to the compiler magic around AnyHashable).
    self.init(codable.elements.map { $0.map { ($0 as Any) as! AnyHashable } })
  }
}

extension FlowPath.CodableRepresentation: Encodable {
  fileprivate func generalEncodingError(_ description: String) -> EncodingError {
    let context = EncodingError.Context(codingPath: [], debugDescription: description)
    return EncodingError.invalidValue(elements, context)
  }

  fileprivate static func encodeExistential(_ element: Encodable) throws -> Data {
    func encodeOpened(_ element: some Encodable) throws -> Data {
      try FlowPath.CodableRepresentation.encoder.encode(element)
    }
    return try _openExistential(element, do: encodeOpened(_:))
  }

  /// Encodes the representation into the encoder's unkeyed container.
  /// - Parameter encoder: The encoder to use.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in elements.reversed() {
      guard let typeName = _mangledTypeName(type(of: element.screen)) else {
        throw generalEncodingError(
          "Unable to create '_mangledTypeName' from \(String(describing: type(of: element)))"
        )
      }
      try container.encode(element.style)
      try container.encode(typeName)
      #if swift(<5.7)
        let data = try Self.encodeExistential(element.screen)
        let string = String(decoding: data, as: UTF8.self)
        try container.encode(string)
      #else
        let string = try String(decoding: Self.encoder.encode(element.screen), as: UTF8.self)
        try container.encode(string)
      #endif
    }
  }
}

extension FlowPath.CodableRepresentation: Decodable {
  public init(from decoder: Decoder) throws {
    var container = try decoder.unkeyedContainer()
    elements = []
    while !container.isAtEnd {
      let style = try container.decode(RouteStyle.self)
      let typeName = try container.decode(String.self)
      guard let type = _typeByName(typeName) else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Cannot instantiate type from name '\(typeName)'."
        )
      }
      guard let codableType = type as? Codable.Type else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "\(typeName) does not conform to Codable."
        )
      }
      let encodedValue = try container.decode(String.self)
      let data = Data(encodedValue.utf8)
      #if swift(<5.7)
        func decodeExistential(type: Codable.Type) throws -> Codable {
          func decodeOpened<A: Codable>(type _: A.Type) throws -> A {
            try FlowPath.CodableRepresentation.decoder.decode(A.self, from: data)
          }
          return try _openExistential(type, do: decodeOpened)
        }
        let value = try decodeExistential(type: codableType)
      #else
        let value = try Self.decoder.decode(codableType, from: data)
      #endif
      elements.insert(Route(screen: value, style: style), at: 0)
    }
  }
}

extension FlowPath.CodableRepresentation: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    do {
      let encodedLhs = try encodeExistential(lhs)
      let encodedRhs = try encodeExistential(rhs)
      return encodedLhs == encodedRhs
    } catch {
      return false
    }
  }
}
