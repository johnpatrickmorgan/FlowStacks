import Foundation

/// A thin wrapper around an array. PFlow provides some convenience methods for presenting and dismissing.
public struct PFlow<Screen> {
    
    /// The underlying array of screens.
    public internal(set) var array: [(Screen, PresentationOptions)]
    
    /// Initializes the stack with an empty array of screens.
    public init() {
        self.array = []
    }
    
    /// Initializes the stack with a single root screen.
    /// - Parameter root: The root screen.
    public init(root: Screen) {
        self.array = [(root, .init(style: .default))]
    }
    
    /// Pushes a new screen onto the stack.
    /// - Parameter screen: The screen to present.
    /// - Parameter style: How to present the screen.
    /// - Parameter onDismiss: Called when the presented view is later
    /// dismissed.
    public mutating func present(_ screen: Screen, style: PresentationStyle = .default, onDismiss: (() -> Void)? = nil) {
        let options = PresentationOptions(style: style, onDismiss: onDismiss)
        array.append((screen, options))
    }
    
    /// Dismisses the top screen off the stack.
    public mutating func dismiss() {
        array = array.dropLast()
    }
}
