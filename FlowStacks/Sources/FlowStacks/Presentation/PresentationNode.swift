import Foundation
import SwiftUI

/// A view that represents a linked list of views, each presenting the next in
/// a presentation stack.
indirect enum PresentationNode<Screen, V: View>: View {
    
    case view(V, presenting: PresentationNode<Screen, V>, stack: Binding<[(Screen, PresentationOptions)]>, index: Int, options: PresentationOptions)
    case end
    
    private var isActiveBinding: Binding<Bool> {
        switch self {
        case .end, .view(_, .end, _, _, _):
            return .constant(false)
        case .view(_, .view, let stack, let index, _):
            return Binding(
                get: {
                    return stack.wrappedValue.count > index + 1
                },
                set: { isPresented in
                    guard !isPresented else { return }
                    guard stack.wrappedValue.count > index + 1 else { return }
                    stack.wrappedValue = Array(stack.wrappedValue.prefix(index + 1))
                }
            )
        }
    }
    
    @ViewBuilder
    private var presentingView: some View {
        switch self {
        case .end:
            EmptyView()
        case .view(let view, _, _, _, _):
            view
        }
    }
    
    @ViewBuilder
    private var presentedView: some View {
        switch self {
        case .end:
            EmptyView()
        case .view(_, let node, _, _, _):
            node
        }
    }
    
    private var presentedOptions: PresentationOptions? {
        switch self {
        case .end, .view(_, .end, _, _, _):
            return nil
        case .view(_, .view(_, _, _, _, let options), _, _, _):
            return options
        }
    }
    
    var body: some View {
#if os(macOS)
        presentingView
            .sheet(
                isPresented: isActiveBinding,
                onDismiss: nil,
                content: { presentedView }
            )
#else
        if #available(iOS 14.0, tvOS 14.0, *) {
            presentingView
                .fullScreenCover(
                    isPresented: presentedOptions?.style == .fullScreenCover ? isActiveBinding : .constant(false),
                    onDismiss: presentedOptions?.onDismiss,
                    content: { presentedView }
                )
                .sheet(
                    isPresented: presentedOptions?.style == .sheet ? isActiveBinding : .constant(false),
                    onDismiss: presentedOptions?.onDismiss,
                    content: { presentedView }
                )
        } else {
            presentingView
                .sheet(
                    isPresented: isActiveBinding,
                    onDismiss: nil,
                    content: { presentedView }
                )
        }
#endif
    }
}
