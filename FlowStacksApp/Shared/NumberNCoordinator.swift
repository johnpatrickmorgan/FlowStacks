import SwiftUI
import FlowStacks

struct NumberNCoordinator: View {
    @State var flow = NFlow(root: 0)
    
    var body: some View {
        NStack($flow) { screen, index in
            VStack(spacing: 8) {
                Text("Screen \(index)")
                HStack(spacing: 8) {
                    Button("<-", action: showPrevious)
                    Button("->", action: showNext)
                }
            }
        }
    }
    
    private func showPrevious() {
        $flow.replaceNFlow(newScreens: [2])
    }
    
    private func showNext() {
        $flow.replaceNFlow(newScreens: [5, 8, 13,800, 9])
    }
}

struct NumberNCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        NumberNCoordinator()
    }
}
