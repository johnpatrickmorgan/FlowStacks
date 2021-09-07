import SwiftUI

@main
struct FlowStacksApp: App {
    var body: some Scene {
        WindowGroup {
//            NumberPCoordinator()
//            MixedCoordinator()
//            VMCoordinator(viewModel: .init())
//            VMPCoordinator(viewModel: .init())
            NavigationView {
                NumberNCoordinator()
            }
        }
    }
}
