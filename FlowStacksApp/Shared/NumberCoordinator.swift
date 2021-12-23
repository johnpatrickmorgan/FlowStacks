import FlowStacks
import SwiftUI
import SwiftUINavigation

enum Screen {
  case number(Int)
  case other
}

extension Screen: ExpressibleByIntegerLiteral {
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
            $routes.withDelaysIfUnsupported {
              $0.goBackToRoot()
            }
          },
          goRandom: {
            $routes.withDelaysIfUnsupported {
              $0 = randomRoutes
            }
          }
        )
      } else {
        EmptyView()
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
  let goRandom: () -> Void
  
  var body: some View {
    VStack(spacing: 8) {
      Stepper("\(number)", value: $number)
      Button("Present Double (cover)") { presentDoubleCover(number) }
      Button("Present Double (sheet)") { presentDoubleSheet(number) }
      Button("Push next") { pushNext(number) }
      if let goBack = goBack {
        Button("Go back", action: goBack)
      }
      Button("Go back to root", action: goBackToRoot)
      Button("Go random", action: goRandom)
    }
    .padding()
    .navigationTitle("\(number)")
  }
}
