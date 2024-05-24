import Foundation

enum Deeplink {
  case numberCoordinator(NumberDeeplink)
  case viewModelTab(ViewModelTabDeeplink)

  init?(url: URL) {
    guard url.scheme == "flowstacksapp" else { return nil }
    switch url.host {
    case "numbers":
      guard let numberDeeplink = NumberDeeplink(pathComponents: url.pathComponents.dropFirst()) else {
        return nil
      }
      self = .numberCoordinator(numberDeeplink)
    case "vm-numbers":
      guard let numberDeeplink = ViewModelTabDeeplink(pathComponents: url.pathComponents.dropFirst()) else {
        return nil
      }
      self = .viewModelTab(numberDeeplink)

    default:
      return nil
    }
  }
}

enum NumberDeeplink {
  case numbers([Int])

  init?(pathComponents: some Collection<String>) {
    let numbers = pathComponents.compactMap(Int.init)
    guard numbers.count == pathComponents.count else {
      return nil
    }
    self = .numbers(numbers)
  }
}

enum ViewModelTabDeeplink {
  case numbers([Int])

  init?(pathComponents: some Collection<String>) {
    let numbers = pathComponents.compactMap(Int.init)
    guard numbers.count == pathComponents.count else {
      return nil
    }
    self = .numbers(numbers)
  }
}
