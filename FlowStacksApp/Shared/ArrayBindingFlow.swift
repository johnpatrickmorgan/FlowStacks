import FlowStacks
import SwiftUI

enum ScreenData: Hashable {
  case numberList(NumberList)
  case number(Int)
  case emojiVisualisation(EmojiVisualisation)
  case childFlow(text: String)
  case childFlowScreen(ChildFlowScreen)
}

struct ArrayBindingFlow: View {
  @State var routes: [Route<ScreenData>] = []
  
  var body: some View {
    FlowStack($routes) {
      HomeView()
        .flowDestination(for: ScreenData.self) { screenData in
          switch (screenData) {
          case .numberList(let numberList):
            NumberListView(numberList: numberList)
          case .number(let number):
            NumberView(number: number)
          case .emojiVisualisation(let visualisation):
            EmojiView(visualisation: visualisation)
          case .childFlow(let text):
            ChildFlow(text: text)
          case .childFlowScreen(let childFlowScreen):
            fatalError()
          }
        }
    }
  }
}

// Home

private struct HomeView: View {
  @EnvironmentObject var navigator: FlowNavigator<ScreenData>

  var body: some View {
    VStack(spacing: 8) {
      FlowLink(ScreenData.numberList(NumberList(range: 0 ..< 100)), style: .push, label: { Text("Pick a number") })
      Button("99 Red balloons", action: show99RedBalloons)
    }.navigationTitle("Home")
  }

  func show99RedBalloons() {
    navigator.withDelaysIfUnsupported {
      $0.push(ScreenData.number(99))
      $0.push(ScreenData.emojiVisualisation(EmojiVisualisation(emoji: "🎈", count: 99)))
    }
  }
}

// NumberList

private struct NumberListView: View {
  let numberList: NumberList
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        FlowLink(ScreenData.number(number), style: .push) {
          Text("\(number)")
        }
      }
    }.navigationTitle("List")
  }
}

// Number

private struct NumberView: View {
  @EnvironmentObject var navigator: FlowNavigator<ScreenData>
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
        ScreenData.number(number + 1),
        style: .push,
        label: { Text("Show next number") }
      )
      FlowLink(
        ScreenData.emojiVisualisation(EmojiVisualisation(emoji: "🐑", count: number)),
        style: .push,
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
    FlowLink(ScreenData.childFlow(text: visualisation.text), style: .sheet(withNavigation: true)) {
      Text("Present text editor")
    }
  }
}

enum ChildFlowScreen: Hashable {
  case edit(String)
}

private struct ChildFlow: View {
  @State var text: String
  
  var body: some View {
    VStack {
      Text(text)
      FlowLink(ChildFlowScreen.edit(text), style: .push, label: { Text("Edit text" )})
    }
      .flowDestination(for: ChildFlowScreen.self, destination: { screen in
        switch screen {
        case .edit:
          EditTextView(text: text, onConfirm: onConfirm)
        }
      })
  }
  
  func onConfirm(newText: String) {
    text = newText
  }
}

private struct EditTextView: View {
  @EnvironmentObject var navigator: FlowNavigator<ChildFlowScreen>
  @State var text: String
  let onConfirm: (String) -> Void
  
  var body: some View {
    VStack {
      TextField("Edit", text: $text)
      Button("Confirm") {
        onConfirm(text)
        navigator.goBack()
      }
    }
  }
}
