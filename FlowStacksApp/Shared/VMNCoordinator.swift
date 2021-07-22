import SwiftUI
import FlowStacks

class VMNCoordinatorViewModel: ObservableObject {
    enum Screen {
        case home(HomeView.ViewModel)
        case numberList(NumberListView.ViewModel)
        case numberDetail(NumberDetailView.ViewModel)
    }
    
    @Published var flow = NFlow<Screen>()
    let showMore: () -> Void
    
    init(showMore: @escaping () -> Void = {}) {
        self.showMore = showMore
        
        flow.push(.home(.init(pickANumberSelected: showNumberList)))
    }
    
    func showNumberList() {
        flow.push(.numberList(.init(numberSelected: showNumber, cancel: pop)))
    }
    
    func showNumber(_ number: Int) {
        flow.push(.numberDetail(.init(number: number, showMore: showMore, cancel: popToRoot)))
    }
    
    func pop() {
        flow.pop()
    }
    
    func popToRoot() {
        flow.popToRoot()
    }
}

struct VMNCoordinator: View {
    
    @ObservedObject var viewModel = VMNCoordinatorViewModel()
    
    var body: some View {
        NavigationView {
            NStack($viewModel.flow) { screen in
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
}

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
        let numbers = 1...100
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
        let showMore: () -> Void
        let cancel: () -> Void
        
        init(number: Int, showMore: @escaping () -> Void = {}, cancel: @escaping () -> Void) {
            self.number = number
            self.showMore = showMore
            self.cancel = cancel
        }
    }
    
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("\(viewModel.number)")
            Button("Go back", action: viewModel.cancel)
            Button("Show more", action: viewModel.showMore)
            Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Number \(viewModel.number)")
    }
}
