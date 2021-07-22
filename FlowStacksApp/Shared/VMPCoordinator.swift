import SwiftUI
import FlowStacks

class VMPCoordinatorViewModel: ObservableObject {
    enum Screen {
        case home(HomeView.ViewModel)
        case numberList(NumberListView.ViewModel)
        case numberDetail(NumberDetailView.ViewModel)
    }
    
    @Published var flow = PFlow<Screen>()
    let showMore: () -> Void
    
    init(showMore: @escaping () -> Void = {}) {
        self.showMore = showMore
        
        flow.present(.home(.init(pickANumberSelected: showNumberList)))
    }
    
    func showNumberList() {
        flow.present(.numberList(.init(numberSelected: showNumber, cancel: dismiss)))
    }
    
    func showNumber(_ number: Int) {
        flow.present(.numberDetail(.init(number: number, showMore: showMore, cancel: dismissToRoot)))
    }
    
    func dismiss() {
        flow.dismiss()
    }
}

struct VMPCoordinator: View {
    
    @ObservedObject var viewModel = VMPCoordinatorViewModel()
    
    var body: some View {
        PStack($viewModel.flow) { screen in
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
