import SwiftUI

public struct NStack<Screen, V: View>: View {
    
    @Binding var stack: [Screen]
    @ViewBuilder var buildView: (Screen) -> V
    
    public var body: some View {
        stack
            .enumerated()
            .reversed()
            .reduce(NavNode<Screen, V>.unlinked) { pushedView, new in
                let (index, screen) = new
                return NavNode<Screen, V>.linked(
                    view: buildView(screen),
                    pushing: pushedView,
                    stack: $stack,
                    index: index
                )
            }
    }
}

indirect enum NavNode<Screen, V: View>: View {
    
    case linked(view: V, pushing: NavNode<Screen, V>, stack: Binding<[Screen]>, index: Int)
    case unlinked
    
    var body: some View {
        if case .linked(let view, let pushedView, let stack, let index) = self {
            ZStack {
                NavigationLink(
                    destination: pushedView,
                    isActive: Binding(
                        get: {
                            if case .unlinked = pushedView {
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
