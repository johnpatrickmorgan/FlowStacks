import SwiftUI
import FlowStacks

struct NumberNCoordinator: View {
    @State var flow = NFlow(root: 0)
    
    var body: some View {
        NStack($flow) { screen in
            VStack(spacing: 8) {
                Text("Screen \(screen)")
                HStack(spacing: 8) {
                    Button("<-", action: showPrevious)
                    Button("->", action: showNext)
                }
            }
        }
    }
    
    private func showPrevious() {
        flow.pop()
    }
    
    private func showNext() {
        let index = flow.array.count
        flow.push(index)
    }
}

struct NumberNCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        NumberNCoordinator()
    }
}
