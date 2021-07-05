import Foundation
import SwiftUI

/// NStack maintains a stack of pushed views for use within a `NavigationView`.
public struct NStack<Screen, ScreenView: View>: View {
    
    /// The array of screens that represents the navigation stack.
    @Binding var stack: [Screen]
    
    /// A closure that builds a `ScreenView` from a `Screen`.
    @ViewBuilder var buildView: (Screen) -> ScreenView
    
    /// Initializer for creating an NStack using a binding to an array of screens.
    /// - Parameters:
    ///   - stack: A binding to an array of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
    public init(_ stack: Binding<[Screen]>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
        self._stack = stack
        self.buildView = buildView
    }
    
    public var body: some View {
        stack
            .enumerated()
            .reversed()
            .reduce(NavigationNode<Screen, ScreenView>.end) { pushedNode, new in
                let (index, screen) = new
                return NavigationNode<Screen, ScreenView>.view(
                    buildView(screen),
                    pushing: pushedNode,
                    stack: $stack,
                    index: index
                )
            }
    }
}

public extension NStack {
    
    /// Convenience initializer for creating an NStack using a binding to a `Stack`
    /// of screens.
    /// - Parameters:
    ///   - stack: A binding to a stack of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
    init(_ stack: Binding<Stack<Screen>>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
        self._stack = Binding(
            get: { stack.wrappedValue.array },
            set: { stack.wrappedValue.array = $0 }
        )
        self.buildView = buildView
    }
}
