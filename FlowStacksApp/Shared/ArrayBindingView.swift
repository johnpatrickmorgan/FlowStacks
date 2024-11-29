import FlowStacks
import SwiftUI

private enum Screen: Hashable {
  case number(Int)
  case numberList(NumberList)
  case visualisation(EmojiVisualisation)
  case child(ChildFlowStack.ChildType)
}

struct ArrayBindingView: View {
  @State private var savedRoutes: [Route<Screen>]?
  @State private var routes: [Route<Screen>] = []

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
            case let .numberList(numberList):
              NumberListView(numberList: numberList)
            case let .number(number):
              NumberView(number: number)
            case let .visualisation(visualisation):
              EmojiView(visualisation: visualisation)
            case let .child(child):
              ChildFlowStack(childType: child)
            }
          })
      }
    }
  }

  func saveRoutes() {
    savedRoutes = routes
  }

  func restoreRoutes() {
    guard let savedRoutes else { return }
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
        .indexedA11y("Pick a number")
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
        FlowLink("\(number)", value: Screen.number(number), style: .push)
          .indexedA11y("Show \(number)")
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
      SimpleStepper(number: $number)
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
      // NOTE: When presenting a child that handles its own state, the child determines whether its root is shown with navigation.
      FlowLink(value: Screen.child(.flowPath), style: .sheet(withNavigation: false), label: { Text("FlowPath Child") })
        .indexedA11y("FlowPath Child")
      FlowLink(value: Screen.child(.noBinding), style: .sheet(withNavigation: false), label: { Text("NoBinding Child") })
        .indexedA11y("NoBinding Child")
      Button("Go back to root", action: { navigator.goBackToRoot() })
        .indexedA11y("Go back to root")
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

// MARK: - State

private struct EmojiVisualisation: Hashable, Codable {
  let emoji: String
  let count: Int

  var text: String {
    Array(repeating: emoji, count: count).joined()
  }
}

private struct NumberList: Hashable, Codable {
  let range: Range<Int>
}

private class ClassDestination {
  let data: String

  init(data: String) {
    self.data = data
  }
}

extension ClassDestination: Hashable {
  static func == (lhs: ClassDestination, rhs: ClassDestination) -> Bool {
    lhs.data == rhs.data
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(data)
  }
}

private class SampleClassDestination: ClassDestination {
  init() { super.init(data: "Sample data") }
}

private struct ChildFlowStack: View {
  enum ChildType: Hashable {
    case flowPath, noBinding
  }

  let childType: ChildType

  var body: some View {
    switch childType {
    case .flowPath:
      FlowPathView()
    case .noBinding:
      NoBindingView()
    }
  }
}
