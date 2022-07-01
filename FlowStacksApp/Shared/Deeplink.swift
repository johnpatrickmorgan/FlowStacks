import Foundation

enum Deeplink {
  case numberCoordinator(NumberDeeplink)
  
  init?(url: URL) {
    guard url.scheme == "flowstacksapp" else { return nil }
    switch url.host {
    case "numbers":
      guard let numberDeeplink = NumberDeeplink(pathComponents: url.pathComponents.dropFirst()) else {
        return nil
      }
      self = .numberCoordinator(numberDeeplink)
    default:
      return nil
    }
  }
}

enum NumberDeeplink {
  case numbers([Int])
  
  init?<C: Collection>(pathComponents: C) where C.Element == String {
    let numbers = pathComponents.compactMap(Int.init)
    guard numbers.count == pathComponents.count else {
      return nil
    }
    self = .numbers(numbers)
  }
}
