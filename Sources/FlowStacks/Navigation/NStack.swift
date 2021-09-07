import Foundation
import SwiftUI

/// NStack maintains a stack of pushed views for use within a `NavigationView`.
public struct NStack<Screen, ScreenView: View>: View {
    
    /// The array of screens that represents the navigation stack.
    @Binding var stack: [Screen]
    
    /// A closure that builds a `ScreenView` from a `Screen`and its index.
    @ViewBuilder var buildView: (Screen, Int) -> ScreenView
    
    /// Initializer for creating an NStack using a binding to an array of screens.
    /// - Parameters:
    ///   - stack: A binding to an array of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen` and its index.
    public init(_ stack: Binding<[Screen]>, @ViewBuilder buildView: @escaping (Screen, Int) -> ScreenView) {
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
                    buildView(screen, index),
                    pushing: pushedNode,
                    stack: $stack,
                    index: index
                )
            }
    }
}

public extension NStack {
    
    /// Convenience initializer for creating an NStack using a binding to a `NFlow`
    /// of screens.
    /// - Parameters:
    ///   - stack: A binding to a stack of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
    init(_ nFlow: Binding<NFlow<Screen>>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
        self._stack = Binding(
            get: { nFlow.wrappedValue.array },
            set: { nFlow.wrappedValue.array = $0 }
        )
        self.buildView = { screen, _ in buildView(screen) }
    }
    
    /// Convenience initializer for creating an NStack using a binding to a `NFlow`
    /// of screens.
    /// - Parameters:
    ///   - stack: A binding to a stack of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen` and its index.
    init(_ nFlow: Binding<NFlow<Screen>>, @ViewBuilder buildView: @escaping (Screen, Int) -> ScreenView) {
        self._stack = Binding(
            get: { nFlow.wrappedValue.array },
            set: { nFlow.wrappedValue.array = $0 }
        )
        self.buildView = buildView
    }
    
    /// Convenience initializer for creating an NStack without using an index in the
    /// `buildView` closure.
    /// - Parameters:
    ///   - stack: A binding to a stack of screens.
    ///   - buildView: A closure that builds a `ScreenView` from a `Screen`.
    init(_ stack: Binding<[Screen]>, @ViewBuilder buildView: @escaping (Screen) -> ScreenView) {
        self._stack = stack
        self.buildView = { screen, _ in buildView(screen) }
    }
}
