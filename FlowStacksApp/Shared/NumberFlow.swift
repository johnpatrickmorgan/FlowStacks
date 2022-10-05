import FlowStacks
import SwiftUI
import SwiftUINavigation

typealias Screen = Int

struct NumberFlow: View {
  @State var initialNumber = 0
  @State var routes: Routes<Screen> = []
  
  var randomRoutes: [Route<Screen>] {
    let options: [[Route<Screen>]] = [
      [],
      [.push(1), .push(2), .push(3), .sheet(4, withNavigation: true), .push(5)],
      [.push(1), .push(2), .push(3)],
      [.push(1), .sheet(2, withNavigation: true), .push(3), .sheet(4, withNavigation: true), .push(5)],
      [.sheet(1, withNavigation: true), .cover(2, withNavigation: true), .push(3), .sheet(4, withNavigation: true), .push(5)]
    ]
    return options.randomElement()!
  }
  
  var body: some View {
    FlowStack($routes, withNavigation: true) {
      NumberView(
        number: $initialNumber,
        goRandom: goRandom
      )
      .flowDestination(for: Int.self) { $number in
        NumberView(
          number: $number,
          goRandom: goRandom
        )
      }
    }
    .onOpenURL { url in
      guard let deeplink = Deeplink(url: url) else { return }
      follow(deeplink)
    }
  }
  
  private func goRandom() {
    $routes.withDelaysIfUnsupported {
      $0 = randomRoutes
    }
  }
  
  private func follow(_ deeplink: Deeplink) {
    guard case .numberFlow(let link) = deeplink else {
      return
    }
    switch link {
    case .numbers(let numbers):
      $routes.withDelaysIfUnsupported {
        for number in numbers {
          $0.push(number)
        }
      }
    }
  }
}

private struct NumberView: View {
  @Binding var number: Int
  @EnvironmentObject var navigator: FlowNavigator<Screen>
  
  let goRandom: (() -> Void)?
  
  var body: some View {
    VStack(spacing: 8) {
      Stepper("\(number)", value: $number)
      FlowLink(number * 2, style: .cover(withNavigation: true), label: { Text("Present Double (cover)") })
      FlowLink(number * 2, style: .sheet(withNavigation: true), label: { Text("Present Double (sheet)") })
      FlowLink(number + 1, style: .push, label: { Text("Push next") })
      if let goRandom = goRandom {
        Button("Go random", action: goRandom)
      }
      if !navigator.isEmpty {
        Button("Go back", action: { navigator.goBack() })
      }
      Button("Go back to root", action: {
        navigator.withDelaysIfUnsupported {
          $0.goBackToRoot()
        }
      })
    }
    .padding()
    .navigationTitle("\(number)")
  }
}
