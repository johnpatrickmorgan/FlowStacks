import FlowStacks
import SwiftUI

struct NumberCoordinator: View {
  @State var initialNumber = 0
  @State var routes: Routes<Int> = []

  func goRandom() {
    let options: [[Route<Int>]] = [
      [],
      [.push(1), .push(2), .push(3), .sheet(4, withNavigation: true), .push(5)],
      [.push(1), .push(2), .push(3)],
      [.push(1), .sheet(2, withNavigation: true), .push(3), .sheet(4, withNavigation: true), .push(5)],
      [.sheet(1, withNavigation: true), .cover(2, withNavigation: true), .push(3), .sheet(4, withNavigation: true), .push(5)],
    ]
    routes = options.randomElement()!
  }

  var body: some View {
    FlowStack($routes, withNavigation: true, navigationViewModifier: AccentColorModifier(color: .green)) {
      NumberView(number: $initialNumber, goRandom: goRandom)
        .flowDestination(for: Int.self) { number in
          NumberView(
            number: number,
            goRandom: goRandom
          )
        }
    }
    .onOpenURL { url in
      guard let deeplink = Deeplink(url: url) else { return }
      follow(deeplink)
    }
  }

  @MainActor
  private func follow(_ deeplink: Deeplink) {
    guard case let .numberCoordinator(link) = deeplink else {
      return
    }
    switch link {
    case let .numbers(numbers):
      for number in numbers {
        routes.push(number)
      }
    }
  }
}

private struct NumberView: View {
  @EnvironmentObject var navigator: FlowNavigator<Int>
  @Environment(\.routeStyle) var routeStyle
  @Environment(\.routeIndex) var routeIndex

  @State private var colorShown: Color?
  @Binding var number: Int
  let goRandom: (() -> Void)?

  var body: some View {
    VStack(spacing: 8) {
      SimpleStepper(number: $number)
      Button("Present Double (cover)") {
        navigator.presentCover(number * 2, withNavigation: true)
      }
      .accessibilityIdentifier("Present Double (cover) from \(number)")
      Button("Present Double (sheet)") {
        navigator.presentSheet(number * 2, withNavigation: true)
      }
      .accessibilityIdentifier("Present Double (sheet) from \(number)")
      Button("Push next") {
        navigator.push(number + 1)
      }
      .accessibilityIdentifier("Push next from \(number)")
      Button("Show red") { colorShown = .red }
        .accessibilityIdentifier("Show red from \(number)")
      if let goRandom {
        Button("Go random", action: goRandom)
      }
      if navigator.canGoBack() {
        Button("Go back") { navigator.goBack() }
          .accessibilityIdentifier("Go back from \(number)")
        Button("Go back to root") { navigator.goBackToRoot() }
          .accessibilityIdentifier("Go back to root from \(number)")
      }
      if let routeStyle, let routeIndex {
        Text("\(routeStyle.description) (\(routeIndex))")
          .font(.footnote).foregroundColor(.gray)
      }
    }
    .padding()
    .background(Color.white)
    .flowDestination(item: $colorShown, style: .sheet(withNavigation: true)) { color in
      Text(String(describing: color)).foregroundColor(color)
        .navigationTitle("Color")
    }
    .navigationTitle("\(number)")
  }
}

// Included so that the same example code can be used for macOS too.
#if os(macOS)
  extension Route {
    static func cover(_ screen: Screen, withNavigation: Bool = false) -> Route {
      sheet(screen, withNavigation: withNavigation)
    }
  }

  extension RouteStyle {
    static func cover(withNavigation: Bool = false) -> RouteStyle {
      .sheet(withNavigation: withNavigation)
    }
  }

  extension Array where Element: RouteProtocol {
    mutating func presentCover(_ screen: Element.Screen, withNavigation: Bool = false) {
      presentSheet(screen, withNavigation: withNavigation)
    }
  }

  extension FlowNavigator {
    func presentCover(_ screen: Screen, withNavigation: Bool = false) {
      presentSheet(screen, withNavigation: withNavigation)
    }
  }
#endif

struct AccentColorModifier: ViewModifier {
  let color: Color

  func body(content: Content) -> some View {
    if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
      content.tint(color)
    } else {
      content.accentColor(color)
    }
  }
}

private extension RouteStyle {
  var description: String {
    switch self {
    case .push:
      return "push"
    case let .cover(withNavigation):
      return "cover" + (withNavigation ? "WithNavigation" : "")
    case let .sheet(withNavigation):
      return "sheet" + (withNavigation ? "WithNavigation" : "")
    }
  }
}
