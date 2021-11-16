import SwiftUI
import FlowStacks

struct MixedCoordinator: View {
  
  enum Screen {
    case number(Int)
  }
  
  @State var routes: [Route<Screen>] = .root(.number(1), embedInNavigationView: true)
  
  var body: some View {
    Router($routes) { screen, index in
      switch screen {
      case .number(let number):
        NumberView(
          number: number,
          presentDoubleCover: { number in
            routes.append(.cover(.number(number * 2), embedInNavigationView: true))
          },
          presentDoubleSheet: { number in
            routes.append(.sheet(.number(number * 2), embedInNavigationView: true))
          },
          pushNext: { number in
            routes.append(.push(.number(number + 1)))
          },
          unwind: { routes = routes.dropLast() },
          popToRoot: { routes = Array(routes.prefix(1)) }
        )
      }
    }
  }
}

struct NumberView: View {
  
  let number: Int
  
  let presentDoubleCover: (Int) -> Void
  let presentDoubleSheet: (Int) -> Void
  let pushNext: (Int) -> Void
  let unwind: () -> Void
  let popToRoot: () -> Void
  
  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)")
      Button("Present Double (cover)") { presentDoubleCover(number) }
      Button("Present Double (sheet)") { presentDoubleSheet(number) }
      Button("Push next") { pushNext(number) }
      Button("Unwind", action: unwind)
      Button("Pop to root", action: popToRoot)
    }.navigationTitle("\(number)")
  }
}
