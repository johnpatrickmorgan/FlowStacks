import FlowStacks
import SwiftUI

struct FlowPathView: View {
  @State var encodedPathData: Data?
  @State var path = FlowPath()

  var body: some View {
    VStack {
      HStack {
        Button("Encode", action: encodePath)
          .disabled(try! encodedPathData == JSONEncoder().encode(path.codable))
        Button("Decode", action: decodePath)
          .disabled(encodedPathData == nil)
      }
      FlowStack($path, withNavigation: true) {
        HomeView()
          .flowDestination(for: NumberList.self, destination: { numberList in
            NumberListView(numberList: numberList)
          })
          .flowDestination(for: Number.self, destination: { $number in
            NumberView(number: $number.value)
          })
          .flowDestination(for: EmojiVisualisation.self, destination: { visualisation in
            EmojiView(visualisation: visualisation)
          })
          .flowDestination(for: ClassDestination.self, destination: { destination in
            ClassDestinationView(destination: destination)
          })
          .flowDestination(for: ChildFlowStack.ChildType.self) { childType in
            ChildFlowStack(childType: childType)
          }
      }
    }
  }

  func encodePath() {
    guard let codable = path.codable else {
      return
    }
    encodedPathData = try! JSONEncoder().encode(codable)
  }

  func decodePath() {
    guard let encodedPathData else {
      return
    }
    let codable = try! JSONDecoder().decode(FlowPath.CodableRepresentation.self, from: encodedPathData)
    path = FlowPath(codable)
  }
}

private struct HomeView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  @State var isPushing = false

  var body: some View {
    VStack(spacing: 8) {
      // Push via link
      FlowLink(
        value: NumberList(range: 0 ..< 10),
        style: .sheet(withNavigation: true),
        label: { Text("Pick a number") }
      ).indexedA11y("Pick a number")
      // Push via navigator
      Button("99 Red balloons", action: show99RedBalloons)
      // Push child class via navigator
      Button("Show Class Destination", action: showClassDestination)
      // Push via Bool binding
      Button("Push local destination", action: { isPushing = true }).disabled(isPushing)
    }
    .flowDestination(isPresented: $isPushing, style: .push, destination: {
      Text("Local destination")
    })
    .navigationTitle("Home")
  }

  func show99RedBalloons() {
    navigator.push(Number(value: 99))
    navigator.push(EmojiVisualisation(emoji: "🎈", count: 99))
  }

  func showClassDestination() {
    navigator.push(SampleClassDestination())
  }
}

private struct NumberListView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        FlowLink("\(number)", value: Number(value: number), style: .push)
          .indexedA11y("Show \(number)")
      }
      Button("Go back", action: { navigator.goBack() })
    }.navigationTitle("List")
  }
}

private struct NumberView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  @Binding var number: Int

  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)").font(.title)
      SimpleStepper(number: $number)
      FlowLink(
        value: Number(value: number + 1),
        style: .push,
        label: { Text("Show next number") }
      )
      FlowLink(
        value: EmojiVisualisation(emoji: "🐑", count: number),
        style: .sheet,
        label: { Text("Visualise with sheep") }
      )
      // NOTE: When presenting a child that handles its own state, the child determines whether its root is shown with navigation.
      FlowLink(value: ChildFlowStack.ChildType.flowPath, style: .sheet(withNavigation: false), label: { Text("FlowPath Child") })
        .indexedA11y("FlowPath Child")
      // NOTE: When presenting a child that defers to the parent state, the parent determines whether it is shown with navigation.
      FlowLink(value: ChildFlowStack.ChildType.noBinding, style: .sheet(withNavigation: true), label: { Text("NoBinding Child") })
        .indexedA11y("NoBinding Child")
      Button("Go back to root", action: { navigator.goBackToRoot() })
        .indexedA11y("Go back to root")
    }.navigationTitle("\(number)")
  }
}

private struct EmojiView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  let visualisation: EmojiVisualisation

  var body: some View {
    VStack {
      Text(visualisation.text)
        .navigationTitle("Visualise \(visualisation.count)")
      Button("Go back", action: { navigator.goBack() })
    }
  }
}

private struct ClassDestinationView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  let destination: ClassDestination

  var body: some View {
    VStack {
      Text(destination.data)
        .navigationTitle("A ClassDestination")
      Button("Go back", action: { navigator.goBack() })
    }
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

private struct Number: Hashable, Codable {
  var value: Int
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

private struct ChildFlowStack: View, Codable {
  enum ChildType: Hashable, Codable {
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
