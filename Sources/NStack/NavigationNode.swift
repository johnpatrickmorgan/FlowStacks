import Foundation
import SwiftUI

/// A view that represents a linked list of views, each pushing the next in
/// a navigation stack.
indirect enum NavigationNode<Screen, V: View>: View {
    
    case view(V, pushing: NavigationNode<Screen, V>, stack: Binding<[Screen]>, index: Int)
    case end
    
    var body: some View {
        if case .view(let view, let pushedView, let stack, let index) = self {
            ZStack {
                NavigationLink(
                    destination: pushedView,
                    isActive: Binding(
                        get: {
                            if case .end = pushedView {
                                return false
                            }
                            return stack.wrappedValue.count > index
                        },
                        set: { isPushed in
                            guard !isPushed else { return }
                            stack.wrappedValue = Array(stack.wrappedValue.prefix(index + 1))
                        }),
                    label: { EmptyView() }
                )
                view
            }
        } else {
            EmptyView()
        }
    }
}
