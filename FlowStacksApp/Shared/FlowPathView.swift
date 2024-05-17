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
          .flowDestination(for: Int.self, destination: { number in
            NumberView(number: number)
          })
          .flowDestination(for: EmojiVisualisation.self, destination: { visualisation in
            EmojiView(visualisation: visualisation)
          })
          .flowDestination(for: ClassDestination.self, destination: { destination in
            ClassDestinationView(destination: destination)
          })
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
    guard let encodedPathData = encodedPathData else {
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
      FlowLink(value: NumberList(range: 0 ..< 10), style: .sheet(withNavigation: true), label: { Text("Pick a number") })
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
    navigator.push(99)
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
        FlowLink("\(number)", value: number, style: .push)
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
        value: EmojiVisualisation(emoji: "🐑", count: number),
        style: .sheet,
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root", action: { navigator.goBackToRoot() })
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
