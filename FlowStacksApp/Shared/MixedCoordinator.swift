import SwiftUI
import FlowStacks

struct MixedCoordinator: View {
  
  typealias Screen = Int
  
  @State var routes: [Route<Screen>] = [.root(0, embedInNavigationView: true)]
  
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
    Router($routes) { $number, _ in
      NumberView(
        number: $number,
        presentDoubleCover: { number in
          routes.presentCover(number * 2, embedInNavigationView: true)
        },
        presentDoubleSheet: { number in
          routes.presentSheet(number * 2, embedInNavigationView: true)
        },
        pushNext: { number in
          routes.push(number + 1)
        },
        goBack: { routes.goBack() },
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
    }
  }
}

struct NumberView: View {
  
  @Binding var number: Int
  
  let presentDoubleCover: (Int) -> Void
  let presentDoubleSheet: (Int) -> Void
  let pushNext: (Int) -> Void
  let goBack: () -> Void
  let goBackToRoot: () -> Void
  let goRandom: () -> Void
  
  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)")
      Stepper("", value: $number)
      Button("Present Double (cover)") { presentDoubleCover(number) }
      Button("Present Double (sheet)") { presentDoubleSheet(number) }
      Button("Push next") { pushNext(number) }
      Button("Go back", action: goBack)
      Button("Go back to root", action: goBackToRoot)
      Button("Go random", action: goRandom)
    }.navigationTitle("\(number)")
  }
}
