import Foundation
import SwiftUI
import FlowStacks
import SwiftUINavigation

struct BindingCoordinator: View {
  enum Screen {
    case start
    case number(Int)
  }
  
  @State var routes: Routes<Screen> = [.root(.start, embedInNavigationView: true)]
    
  var body: some View {
    Router($routes) { $screen, _ in
      if let number = Binding(unwrapping: $screen, case: /Screen.number) {
        // Here number is a Binding<Int>, so NumberView can change its
        // value in the routes array.
        EditableNumberView(number: number)
      } else {
        StartView(goTapped: goTapped)
      }
    }
  }
  
  func goTapped() {
    routes.push(.number(42))
  }
}

struct StartView: View {
  
  let goTapped: () -> Void
  
  var body: some View {
    VStack(alignment: .center, spacing: 8) {
      Button("Go", action: goTapped)
    }.navigationTitle("Home")
  }
}

struct EditableNumberView: View {
  
  @Binding var number: Int
  
  var body: some View {
    VStack(alignment: .center, spacing: 8) {
      Stepper("\(number)", onIncrement: { number += 1 }, onDecrement: { number -= 1 })
    }
    .padding()
    .navigationTitle("\(number)")
  }
}
