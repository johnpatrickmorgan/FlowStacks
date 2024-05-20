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
      $routes.withDelaysIfUnsupported {
        for number in numbers {
          $0.push(number)
        }
      }
    }
  }
}

private struct NumberView: View {
  @EnvironmentObject var navigator: FlowNavigator<Int>
  @Environment(\.routeStyle) var routeStyle: RouteStyle?
  @Environment(\.routeIndex) var routeIndex: Int?

  @Binding var number: Int
  let goRandom: (() -> Void)?

  var body: some View {
    VStack(spacing: 8) {
      Stepper(label: { EmptyView() }, onIncrement: { number += 1 }, onDecrement: { number -= 1 })
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
        Text("\(routeStyle) (\(routeIndex))")
          .font(.footnote).foregroundColor(.gray)
      }
    }
    .padding()
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
    if #available(iOS 16.0, *) {
      content.tint(color)
    } else {
      content.accentColor(color)
    }
  }
}
