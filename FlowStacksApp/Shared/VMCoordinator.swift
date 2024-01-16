import FlowStacks
import SwiftUI

class VMCoordinatorViewModel: ObservableObject {
  enum Screen {
    case home(HomeView.ViewModel)
    case numberList(NumberListView.ViewModel)
    case numberDetail(NumberDetailView.ViewModel)
  }

  @Published var routes: Routes<Screen> = []

  init() {
    routes.presentSheet(.home(.init(pickANumberSelected: showNumberList)), embedInNavigationView: true)
  }

  func showNumberList() {
    routes.push(.numberList(.init(numberSelected: showNumber, cancel: dismiss)))
  }

  func showNumber(_ number: Int) {
    routes.presentSheet(.numberDetail(.init(number: number, cancel: goBackToRoot)))
  }

  func dismiss() {
    routes.goBack()
  }

  func goBackToRoot() {
    RouteSteps.withDelaysIfUnsupported(self, \.routes) {
      $0.goBackToRoot()
    }
  }
}

struct VMCoordinator: View {
  @ObservedObject var viewModel = VMCoordinatorViewModel()

  var body: some View {
    Router($viewModel.routes) { screen, _ in
      switch screen {
      case .home(let viewModel):
        HomeView(viewModel: viewModel)
      case .numberList(let viewModel):
        NumberListView(viewModel: viewModel)
      case .numberDetail(let viewModel):
        NumberDetailView(viewModel: viewModel)
      }
    }
  }
}

// MARK: - Views

struct HomeView: View {
  class ViewModel: ObservableObject {
    let pickANumberSelected: () -> Void

    init(pickANumberSelected: @escaping () -> Void) {
      self.pickANumberSelected = pickANumberSelected
    }
  }

  @ObservedObject var viewModel: ViewModel

  var body: some View {
    VStack {
      Button("Pick a number", action: viewModel.pickANumberSelected)
    }
    .navigationTitle("Home")
  }
}

struct NumberListView: View {
  class ViewModel: ObservableObject {
    let numbers = 1 ... 100
    let numberSelected: (Int) -> Void
    let cancel: () -> Void

    init(numberSelected: @escaping (Int) -> Void, cancel: @escaping () -> Void) {
      self.numberSelected = numberSelected
      self.cancel = cancel
    }
  }

  @ObservedObject var viewModel: ViewModel

  var body: some View {
    VStack(spacing: 12) {
      List(viewModel.numbers, id: \.self) { number in
        Button("\(number)", action: { viewModel.numberSelected(number) })
      }
      Button("Go back", action: viewModel.cancel)
    }
    .navigationTitle("Numbers")
  }
}

struct NumberDetailView: View {
  class ViewModel: ObservableObject {
    let number: Int
    let cancel: () -> Void

    init(number: Int, cancel: @escaping () -> Void) {
      self.number = number
      self.cancel = cancel
    }
  }

  @ObservedObject var viewModel: ViewModel

  @Environment(\.presentationMode) var presentationMode

  @EnvironmentObject var navigator: FlowNavigator<VMCoordinatorViewModel.Screen>
  
  var body: some View {
    VStack {
      Text("\(viewModel.number)")
      Button("Go back to root", action: viewModel.cancel)
      Button("PresentationMode Dismiss") {
        presentationMode.wrappedValue.dismiss()
      }
      Button("Navigator Dismiss") {
        navigator.goBack()
      }
    }
    .navigationTitle("Number \(viewModel.number)")
  }
}
