import SwiftUI

public struct NStack<ViewModel: Hashable, V: View>: View {
    
    @Binding var stack: [ViewModel]
    @ViewBuilder var builder: (ViewModel) -> V
    
    public var body: some View {
        NavigationView {
            stack
                .enumerated()
                .reversed()
                .reduce(NavNode<V>.unlinked) { viewToPush, new in
                    let (index, screen) = new
                    return NavNode.linked(
                        view: builder(screen),
                        pushing: viewToPush,
                        pop: {
                            stack = Array(stack.prefix(index + 1))
                        }
                    )
                }
        }
    }
}

public indirect enum NavNode<V: View>: View {
    
    case linked(view: V, pushing: NavNode<V>, pop: () -> Void)
    case unlinked
    
    var isUnlinked: Bool {
        guard case .unlinked = self else { return false }
        return true
    }
    
    public var body: some View {
        if case .linked(let view, let pushedView, let pop) = self {
            ZStack {
                NavigationLink(
                    destination: pushedView,
                    isActive: Binding(
                        get: { !pushedView.isUnlinked },
                        set: { shouldStayPushed in
                            if !shouldStayPushed {
                                pop()
                            }
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
