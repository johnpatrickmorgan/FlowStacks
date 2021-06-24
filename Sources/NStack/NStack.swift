import Foundation
import SwiftUI

/// NStack maintains a stack of pushed views for use within a `NavigationView`.
public struct NStack<Screen, V: View>: View {
    
    @Binding var stack: [Screen]
    @ViewBuilder var buildView: (Screen) -> V
    
    public var body: some View {
        stack
            .enumerated()
            .reversed()
            .reduce(NavigationNode<Screen, V>.end) { pushedView, new in
                let (index, screen) = new
                return NavigationNode<Screen, V>.view(
                    buildView(screen),
                    pushing: pushedView,
                    stack: $stack,
                    index: index
                )
            }
    }
}

public extension NStack {
    
    init(_ stack: Binding<Stack<Screen>>, @ViewBuilder buildView: @escaping (Screen) -> V) {
        self._stack = Binding(
            get: { stack.wrappedValue.array },
            set: { stack.wrappedValue.array = $0 }
        )
        self.buildView = buildView
    }
}
