import SwiftUI
import FlowStacks

struct MixedCoordinator: View {
    enum Screen {
        case launch
        case vmCoordinator(VMNCoordinatorViewModel)
    }
    
    @State var flow = PFlow<Screen>(root: .launch)
    
    var body: some View {
        PStack($flow) { screen in
            switch screen {
            case .launch:
                Button("Go", action: showVMCoordinator)
            case .vmCoordinator(let vm):
                VMNCoordinator(viewModel: vm)
            }
        }
    }
    
    private func showVMCoordinator() {
        flow.present(.vmCoordinator(.init(showMore: showVMCoordinator)))
    }
}
