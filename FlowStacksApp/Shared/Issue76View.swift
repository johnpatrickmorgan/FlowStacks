import FlowStacks
import SwiftUI

enum Path: Hashable {
  case sport(Int)
}

enum NewPath: Hashable {
  case challenge(String)
}

struct Issue76View: View {
  @State var path = FlowPath()
  var withNavigation: Bool = true

  var body: some View {
    FlowStack($path, withNavigation: withNavigation) {
      VStack {
        Button {
          path.push(Path.sport(1))
        } label: {
          Text("Push")
        }
      }
      .navigationTitle("ROOT")
      .flowDestination(for: Path.self) { screen in
        switch screen {
        case let .sport(value):
          SportView(value: value)
        }
      }
    }
  }
}

struct SportView: View {
  @State var path = FlowPath()

  let value: Int

  var body: some View {
    FlowStack($path) {
      SportHomeView(path: $path, value: value)
      .navigationTitle("Sport")
      .flowDestination(for: NewPath.self) { screen in
        switch screen {
        case let .challenge(value):
          ChallengeView(path: $path, value: value)
        }
      }
    }
  }
}

struct SportHomeView: View {
  @Binding var path: FlowPath
  var value: Int
  
  var body: some View {
      VStack {
        Button {
          path.push(NewPath.challenge("Hi"))
        } label: {
          Text("push")
        }
        Text(value.description)
      }
  }
}
struct ChallengeView: View {
  @Binding var path: FlowPath

  let value: String
  var body: some View {
    VStack {
      Text(value)
      Button {
        path.push(NewPath.challenge("Hello"))
      } label: {
        Text("challenge")
      }
    }
    .navigationTitle("Challenge")
  }
}
