import Foundation
import SwiftUI

/// A view that represents a linked list of views, each pushing the next in
/// a navigation stack.
indirect enum NavigationNode<Screen, V: View>: View {
    
    case view(V, pushing: NavigationNode<Screen, V>, stack: Binding<[Screen]>, index: Int)
    case end
    
    private var isActiveBinding: Binding<Bool> {
        switch self {
        case .end, .view(_, .end, _, _):
            return .constant(false)
        case .view(_, .view, let stack, let index):
            return Binding(
                get: {
                    return stack.wrappedValue.count > index + 1
                },
                set: { isPushed in
                    guard !isPushed else { return }
                    guard stack.wrappedValue.count > index + 1 else { return }
                    stack.wrappedValue = Array(stack.wrappedValue.prefix(index + 1))
                }
            )
        }
    }
    
    @ViewBuilder
    private var pushingView: some View {
        switch self {
        case .end:
            EmptyView()
        case .view(let view, _, _, _):
            view
        }
    }
    
    @ViewBuilder
    private var pushedView: some View {
        switch self {
        case .end:
            EmptyView()
        case .view(_, let node, _, _):
            node
        }
    }
    
    var body: some View {
        pushingView
            .background(
                NavigationLink(destination: pushedView, isActive: isActiveBinding, label: EmptyView.init)
                    // NOTE: If this is set to true, there are some unexpected
                    // pops when pushing more than 3 screens.
                    .isDetailLinkiOS()
                    .hidden()
            )
    }
}

extension NavigationLink {
  func isDetailLinkiOS() -> some View {
    #if os(iOS)
        isDetailLink(false)
    #else
        self
    #endif
  }
}
