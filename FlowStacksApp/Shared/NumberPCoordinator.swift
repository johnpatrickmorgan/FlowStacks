import SwiftUI
import FlowStacks

struct NumberPCoordinator: View {
    @State var flow = PFlow(root: 0)
    
    var body: some View {
        PStack($flow) { screen in
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
        flow.dismiss()
    }
    
    private func showNext() {
        flow.present(flow.array.count)
    }
    
    private func dismiss(count: Int = 1) {
        guard count > 0 else { return }
        flow.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            dismiss(count: count - 1)
        }
    }
}

struct NumberPCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        NumberPCoordinator()
    }
}
