import Combine
import FlowStacks
import SwiftUI

struct NumberVMFlow: View {
  @ObservedObject var viewModel: ViewModel

  var body: some View {
    FlowStack($viewModel.routes, withNavigation: true) {
      NumberVMView(viewModel: viewModel.initialScreenViewModel)
        .flowDestination(for: ScreenViewModel.self) { screenVM in
          if case let .number(vm) = screenVM {
            NumberVMView(viewModel: vm)
          }
        }
    }
    .onOpenURL { url in
      viewModel.open(url)
    }
  }
}

extension NumberVMFlow {
  class ViewModel: ObservableObject {
    let initialScreenViewModel: NumberVMView.ViewModel
    @Published var routes: Routes<ScreenViewModel>

    init(initialNumber: Int, routes: Routes<ScreenViewModel> = []) {
      initialScreenViewModel = .init(number: initialNumber)
      self.routes = routes

      initialScreenViewModel.goRandom = { [weak self] in self?.goRandom() }
    }

    func open(_ url: URL) {
      guard let deepLink = Deeplink(url: url) else {
        return
      }
      follow(deepLink)
    }

    func follow(_ deeplink: Deeplink) {
      guard case let .viewModelTab(link) = deeplink else {
        return
      }
      switch link {
      case let .numbers(numbers):
        for number in numbers {
          routes.push(.number(.init(number: number, goRandom: goRandom)))
        }
      }
    }

    func goRandom() {
      func screenViewModel(_ number: Int) -> ScreenViewModel {
        .number(.init(number: number, goRandom: goRandom))
      }
      let options: [[Route<ScreenViewModel>]] = [
        [],
        [
          .push(screenViewModel(1)),
        ],
        [
          .push(screenViewModel(1)),
          .push(screenViewModel(2)),
          .push(screenViewModel(3)),
        ],
        [
          .push(screenViewModel(1)),
          .push(screenViewModel(2)),
          .sheet(screenViewModel(3), withNavigation: true),
          .push(screenViewModel(4)),
        ],
        [
          .sheet(screenViewModel(1), withNavigation: true),
          .push(screenViewModel(2)),
          .sheet(screenViewModel(3), withNavigation: true),
          .push(screenViewModel(4)),
        ],
      ]
      routes = options.randomElement()!
    }
  }
}

// ScreenVM

enum ScreenViewModel: Hashable {
  case number(NumberVMView.ViewModel)
}

// NumberVMView

struct NumberVMView: View {
  @ObservedObject var viewModel: ViewModel
  @EnvironmentObject var navigator: FlowNavigator<ScreenViewModel>

  var body: some View {
    VStack(spacing: 8) {
      SimpleStepper(number: $viewModel.number)
      FlowLink(value: viewModel.doubleViewModel(), style: .cover(withNavigation: true), label: { Text("Present Double (cover)") })
      FlowLink(value: viewModel.doubleViewModel(), style: .sheet(withNavigation: true), label: { Text("Present Double (sheet)") })
      FlowLink(value: viewModel.incrementedViewModel(), style: .push, label: { Text("Push next") })
      if let goRandom = viewModel.goRandom {
        Button("Go random", action: goRandom)
      }
      if !navigator.routes.isEmpty {
        Button("Go back", action: { navigator.goBack() })
        Button("Go back to root", action: {
          navigator.goBackToRoot()
        })
      }
    }
    .padding()
    .navigationTitle("\(viewModel.number)")
  }
}

extension NumberVMView {
  class ViewModel: ObservableObject, Hashable {
    static func == (lhs: NumberVMView.ViewModel, rhs: NumberVMView.ViewModel) -> Bool {
      lhs.number == rhs.number
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(number)
    }

    @Published var number: Int
    var goRandom: (() -> Void)?

    init(number: Int, goRandom: (() -> Void)? = nil) {
      self.number = number
      self.goRandom = goRandom
    }

    func doubleViewModel() -> ScreenViewModel {
      .number(.init(number: number * 2, goRandom: goRandom))
    }

    func incrementedViewModel() -> ScreenViewModel {
      .number(.init(number: number + 1, goRandom: goRandom))
    }
  }
}
