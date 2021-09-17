import Foundation
import SwiftUI

/// PStack maintains a stack of presented views for use within a `PresentationView`.
public struct PStack<Screen, ScreenView: View>: View {
    
    /// The array of screens that represents the presentation stack.
    @Binding var stack: [(Screen, PresentationOptions)]
    
    /// A closure that builds a `ScreenView` from a `Screen`.
    @ViewBuilder var buildView: (Screen) -> ScreenView
    
    /// Initializer for creating an PStack using a binding to an array of screens.
    /// - Parameters:
    ///   - stack: A binding to an array of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
    public init(_ stack: Binding<[(Screen, PresentationOptions)]>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
        self._stack = stack
        self.buildView = buildView
    }
    
    public var body: some View {
        stack
            .enumerated()
            .reversed()
            .reduce(PresentationNode<Screen, ScreenView>.end) { presentedNode, new in
                let (index, (screen, options)) = new
                return PresentationNode<Screen, ScreenView>.view(
                    buildView(screen),
                    presenting: presentedNode,
                    stack: $stack,
                    index: index,
                    options: options
                )
            }
    }
}

public extension PStack {
    
    /// Convenience initializer for creating an PStack using a binding to a `PFlow`
    /// of screens.
    /// - Parameters:
    ///   - stack: A binding to a PFlow of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
    init(_ stack: Binding<PFlow<Screen>>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
        self._stack = Binding(
            get: { stack.wrappedValue.array },
            set: { stack.wrappedValue.array = $0 }
        )
        self.buildView = buildView
    }
}

public extension PStack {
    
    /// Convenience initializer for creating an PStack using a binding to an array
    /// of screens, using the default presentation style.
    /// - Parameters:
    ///   - stack: A binding to an array of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
    init(_ stack: Binding<[Screen]>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
        self._stack = Binding(
            get: { stack.wrappedValue.map { ($0, .init(style: .default, onDismiss: nil)) } },
            set: { stack.wrappedValue = $0.map { $0.0 } }
        )
        self.buildView = buildView
    }
}
