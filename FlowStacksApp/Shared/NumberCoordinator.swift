import FlowStacks
import SwiftUI
import SwiftUINavigation

enum Screen {
  case number(Int)
  case other
}

extension Screen: ExpressibleByIntegerLiteral, Hashable {
  init(integerLiteral value: Int) {
    self = .number(value)
  }
}

struct NumberCoordinator: View {
  @State var routes: Routes<Screen> = [.root(0, embedInNavigationView: true)]
  
  var randomRoutes: [Route<Screen>] {
    let options: [[Route<Screen>]] = [
      [.root(0, embedInNavigationView: true)],
      [.root(0, embedInNavigationView: true), .push(1), .push(2), .push(3), .sheet(4, embedInNavigationView: true), .push(5)],
      [.root(0, embedInNavigationView: true), .push(1), .push(2), .push(3)],
      [.root(0, embedInNavigationView: true), .push(1), .sheet(2, embedInNavigationView: true), .push(3), .sheet(4, embedInNavigationView: true), .push(5)],
      [.root(0, embedInNavigationView: true), .sheet(1, embedInNavigationView: true), .cover(2, embedInNavigationView: true), .push(3), .sheet(4, embedInNavigationView: true), .push(5)]
    ]
    return options.randomElement()!
  }
  
  var body: some View {
    Router($routes) { $screen, index in
      if let number = Binding(unwrapping: $screen, case: /Screen.number) {
        NumberView(
          number: number,
          presentDoubleCover: { number in
            routes.presentCover(.number(number * 2), embedInNavigationView: true)
          },
          presentDoubleSheet: { number in
            routes.presentSheet(.number(number * 2), embedInNavigationView: true)
          },
          pushNext: { number in
            routes.push(.number(number + 1))
          },
          goBack: index != 0 ? { routes.goBack() } : nil,
          goBackToRoot: {
            Task { @MainActor in
              await $routes.withDelaysIfUnsupported {
                $0.goBackToRoot()
              }
            }
          },
          goRandom: {
            Task { @MainActor in
              await $routes.withDelaysIfUnsupported {
                $0 = randomRoutes
              }
            }
          }
        )
      } else {
        EmptyView()
      }
    }
    .onChange(of: routes) { [oldRoutes = routes] newRoutes in
      let shownRoutes = newRoutes.suffix(from: min(newRoutes.endIndex, oldRoutes.endIndex))
      let unshownRoutes = oldRoutes.suffix(from: min(oldRoutes.endIndex, newRoutes.endIndex)).reversed()
      for route in shownRoutes {
        print("Showed \(route.screen)")
      }
      for route in unshownRoutes {
        print("Unshowed \(route.screen)")
      }
    }
  }
}

struct NumberView: View {
  @Binding var number: Int
  
  let presentDoubleCover: (Int) -> Void
  let presentDoubleSheet: (Int) -> Void
  let pushNext: (Int) -> Void
  let goBack: (() -> Void)?
  let goBackToRoot: () -> Void
  let goRandom: (() -> Void)?
  
  var body: some View {
    VStack(spacing: 8) {
      Stepper("\(number)", value: $number)
      Button("Present Double (cover)") { presentDoubleCover(number) }
      Button("Present Double (sheet)") { presentDoubleSheet(number) }
      Button("Push next") { pushNext(number) }
      if let goRandom = goRandom {
        Button("Go random", action: goRandom)
      }
      if let goBack = goBack {
        Button("Go back", action: goBack)
      }
      Button("Go back to root", action: goBackToRoot)
    }
    .padding()
    .navigationTitle("\(number)")
  }
}

// Included so that the same example code can be used for macOS too.
#if os(macOS)
extension Route {
  
  static func cover(_ screen: Screen, embedInNavigationView: Bool = false) -> Route {
    sheet(screen, embedInNavigationView: embedInNavigationView)
  }
}

extension Array where Element: RouteProtocol {
  
  mutating func presentCover(_ screen: Element.Screen, embedInNavigationView: Bool = false) {
    presentSheet(screen, embedInNavigationView: embedInNavigationView)
  }
}
#endif
