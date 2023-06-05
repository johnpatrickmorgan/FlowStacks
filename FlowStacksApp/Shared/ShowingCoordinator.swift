import FlowStacks
import SwiftUI
import SwiftUINavigation

struct ShowingCoordinator: View {
  @State var routes: Routes<Int> = []

  var body: some View {
    Button("Show 42", action: { routes.push(42) })
      .showing($routes, embedInNavigationView: true) { $number, _ in
        ShownNumberView(number: $number)
      }
  }
}

struct ShownNumberView: View {
  @Binding var number: Int
  @EnvironmentObject var navigator: FlowNavigator<Int>

  var body: some View {
    VStack(spacing: 8) {
      Stepper("\(number)", value: $number)
      Button("Present Double (cover)") {
        navigator.presentCover(number * 2, embedInNavigationView: true)
      }
      Button("Present Double (sheet)") {
        navigator.presentSheet(number * 2, embedInNavigationView: true)
      }
      Button("Push next") {
        navigator.push(number + 1)
      }
      if !navigator.routes.isEmpty {
        Button("Go back") { navigator.goBack() }
      }
    }
    .padding()
    .navigationTitle("\(number)")
  }
}
