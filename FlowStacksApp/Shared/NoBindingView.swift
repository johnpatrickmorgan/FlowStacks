import FlowStacks
import SwiftUI

struct NoBindingView: View {
  var body: some View {
    FlowStack(withNavigation: true) {
      HomeView()
        .flowDestination(for: NumberList2.self, destination: { numberList in
          NumberListView(numberList: numberList)
        })
        .flowDestination(for: Double.self, destination: { number in
          NumberView(number: number)
        })
        .flowDestination(for: EmojiVisualisation2.self, destination: { visualisation in
          EmojiView(visualisation: visualisation)
        })
        .flowDestination(for: ClassDestination2.self, destination: { destination in
          ClassDestinationView(destination: destination)
        })
    }
  }
}

private struct HomeView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  @State var isPushing = false

  var body: some View {
    VStack(spacing: 8) {
      // Push via link
      FlowLink(value: NumberList2(range: 0 ..< 10), style: .sheet(withNavigation: true), label: { Text("Pick a number") })
      // Push via navigator
      Button("99 Red balloons", action: show99RedBalloons)
      // Push child class via navigator
      Button("Show Class Destination", action: showClassDestination)
      // Push via Bool binding
      Button("Push local destination", action: { isPushing = true }).disabled(isPushing)
    }.navigationTitle("Home")
      .flowDestination(isPresented: $isPushing, style: .push, destination: {
        Text("Local destination")
      })
  }

  func show99RedBalloons() {
    navigator.push(99)
    navigator.push(EmojiVisualisation2(emoji: "🎈", count: 99))
  }

  func showClassDestination() {
    navigator.push(SampleClassDestination2())
  }
}

private struct NumberListView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  let numberList: NumberList2
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        FlowLink("\(number)", value: Double(number), style: .push)
      }
      Button("Go back", action: { navigator.goBack() })
    }.navigationTitle("List")
  }
}

private struct NumberView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  @State var number: Double

  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)").font(.title)
      Stepper(
        label: { Text("\(number)") },
        onIncrement: { number += 1 },
        onDecrement: { number -= 1 }
      ).labelsHidden()
      FlowLink(
        value: number + 1,
        style: .push,
        label: { Text("Show next number") }
      )
      FlowLink(
        value: EmojiVisualisation2(emoji: "🐑", count: Int(number)),
        style: .sheet,
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root") {
        navigator.goBackToRoot()
      }
    }.navigationTitle("\(number)")
  }
}

private struct EmojiView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  let visualisation: EmojiVisualisation2

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
  let destination: ClassDestination2

  var body: some View {
    VStack {
      Text(destination.data)
        .navigationTitle("A ClassDestination")
      Button("Go back", action: { navigator.goBack() })
    }
  }
}

struct EmojiVisualisation2: Hashable, Codable {
  let emoji: String
  let count: Int

  var text: String {
    Array(repeating: emoji, count: count).joined()
  }
}

struct NumberList2: Hashable, Codable {
  let range: Range<Int>
}

class ClassDestination2 {
  let data: String

  init(data: String) {
    self.data = data
  }
}

extension ClassDestination2: Hashable {
  static func == (lhs: ClassDestination2, rhs: ClassDestination2) -> Bool {
    lhs.data == rhs.data
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(data)
  }
}

class SampleClassDestination2: ClassDestination {
  init() { super.init(data: "Sample data") }
}
