import FlowStacks
import SwiftUI
import SwiftUINavigation

struct ShowingCoordinator: View {
  @State var routes: Routes<Int> = []
  
  var body: some View {
    Button("Show 42", action: { routes.push(42) })
      .showing($routes, embedInNavigationView: true) { $number, index in
        NumberView(
          number: $number,
          presentDoubleCover: { number in
            routes.presentCover(number * 2 , embedInNavigationView: true)
          },
          presentDoubleSheet: { number in
            routes.presentSheet(number * 2 , embedInNavigationView: true)
          },
          pushNext: { number in
            routes.push(number + 1)
          },
          goBack: { routes.goBack() },
          goBackToRoot: {
            $routes.withDelaysIfUnsupported {
              $0 = []
            }
          },
          goRandom: nil
        )
      }
  }
}
