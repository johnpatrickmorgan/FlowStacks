struct EmojiVisualisation: Hashable, Codable {
  let emoji: String
  let count: Int

  var text: String {
    Array(repeating: emoji, count: count).joined()
  }
}

struct NumberList: Hashable, Codable {
  let range: Range<Int>
}

class ClassDestination {
  let data: String

  init(data: String) {
    self.data = data
  }
}

extension ClassDestination: Hashable {
  static func == (lhs: ClassDestination, rhs: ClassDestination) -> Bool {
    lhs.data == rhs.data
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(data)
  }
}

class SampleClassDestination: ClassDestination {
  init() { super.init(data: "Sample data") }
}
