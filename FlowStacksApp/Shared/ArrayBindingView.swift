import FlowStacks
import SwiftUI

enum Screen: Hashable {
  case number(Int)
  case numberList(NumberList)
  case visualisation(EmojiVisualisation)
}

struct ArrayBindingView: View {
  @State var savedRoutes: [Route<Screen>]?
  @State var routes: [Route<Screen>] = []

  var body: some View {
    VStack {
      HStack {
        Button("Save", action: saveRoutes)
          .disabled(savedRoutes == routes)
        Button("Restore", action: restoreRoutes)
          .disabled(savedRoutes == nil)
      }
      FlowStack($routes, withNavigation: true) {
        HomeView()
          .flowDestination(for: Screen.self, destination: { screen in
            switch screen {
            case .numberList(let numberList):
              NumberListView(numberList: numberList)
            case .number(let number):
              NumberView(number: number)
            case .visualisation(let visualisation):
              EmojiView(visualisation: visualisation)
            }
          })
      }
    }
  }

  func saveRoutes() {
    savedRoutes = routes
  }

  func restoreRoutes() {
    guard let savedRoutes = savedRoutes else { return }
    routes = savedRoutes
  }
}

private struct HomeView: View {
  @State var isPushing = false
  @EnvironmentObject var navigator: FlowNavigator<Screen>

  var body: some View {
    VStack(spacing: 8) {
      // Push via FlowLink
      FlowLink(value: Screen.numberList(NumberList(range: 0 ..< 10)), style: .sheet(withNavigation: true), label: { Text("Pick a number") })
      // Push via navigator
      Button("99 Red balloons", action: show99RedBalloons)
      // Push via Bool binding
      Button("Push local destination", action: { isPushing = true }).disabled(isPushing)
    }.navigationTitle("Home")
      .flowDestination(isPresented: $isPushing, style: .push) {
        Text("Local destination")
      }
  }

  func show99RedBalloons() {
    navigator.push(.number(99))
    navigator.push(.visualisation(EmojiVisualisation(emoji: "🎈", count: 99)))
  }
}

private struct NumberListView: View {
  @EnvironmentObject var navigator: FlowNavigator<Screen>
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        FlowLink("\(number)", value: Screen.number(number), style: .sheet(withNavigation: true))
      }
      Button("Go back", action: { navigator.goBack() })
    }.navigationTitle("List")
  }
}

private struct NumberView: View {
  @EnvironmentObject var navigator: FlowNavigator<Screen>
  @State var number: Int

  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)").font(.title)
      Stepper(
        label: { Text("\(number)") },
        onIncrement: { number += 1 },
        onDecrement: { number -= 1 }
      ).labelsHidden()
      FlowLink(
        value: Screen.number(number + 1),
        style: .push,
        label: { Text("Show next number") }
      )
      FlowLink(
        value: Screen.visualisation(.init(emoji: "🐑", count: number)),
        style: .sheet,
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root", action: { navigator.goBackToRoot() })
    }.navigationTitle("\(number)")
  }
}

private struct EmojiView: View {
  @EnvironmentObject var navigator: FlowNavigator<Screen>
  let visualisation: EmojiVisualisation

  var body: some View {
    Text(visualisation.text)
      .navigationTitle("Visualise \(visualisation.count)")
    Button("Go back", action: { navigator.goBack() })
  }
}
