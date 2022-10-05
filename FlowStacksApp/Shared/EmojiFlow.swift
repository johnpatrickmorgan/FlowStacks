import FlowStacks
import SwiftUI

struct EmojiFlow: View {
  var body: some View {
    FlowStack {
      HomeView()
        .flowDestination(for: NumberList.self, destination: { numberList in
          NumberListView(numberList: numberList)
        })
        .flowDestination(for: Int.self, destination: { number in
          NumberView(number: number)
        })
        .flowDestination(for: EmojiVisualisation.self, destination: { visualisation in
          EmojiView(visualisation: visualisation)
        })
    }
  }
}

// Home

private struct HomeView: View {
  @EnvironmentObject var navigator: FlowPathNavigator

  var body: some View {
    VStack(spacing: 8) {
      FlowLink(NumberList(range: 0 ..< 100), style: .push, label: { Text("Pick a number") })
      Button("99 Red balloons", action: show99RedBalloons)
    }.navigationTitle("Home")
  }

  func show99RedBalloons() {
    navigator.withDelaysIfUnsupported {
      $0.push(99)
      $0.push(EmojiVisualisation(emoji: "🎈", count: 99))
    }
  }
}

// NumberList

struct NumberList: Hashable, Codable {
  let range: Range<Int>
}

private struct NumberListView: View {
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        FlowLink(number, style: .push) {
          Text("\(number)")
        }
      }
    }.navigationTitle("List")
  }
}

// Number

private struct NumberView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
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
        number + 1,
        style: .push,
        label: { Text("Show next number") }
      )
      FlowLink(
        EmojiVisualisation(emoji: "🐑", count: number),
        style: .sheet(),
        label: { Text("Visualise with sheep") }
      )
      Button("Pop to root") {
        navigator.popToRoot()
      }
    }.navigationTitle("\(number)")
  }
}

// Emoji

private struct EmojiView: View {
  let visualisation: EmojiVisualisation

  var body: some View {
    Text(visualisation.text)
      .navigationTitle("Visualise \(visualisation.count)")
  }
}

struct EmojiVisualisation: Hashable, Codable {
  let emoji: String
  let count: Int

  var text: String {
    Array(repeating: emoji, count: count).joined()
  }
}
