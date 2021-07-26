import Foundation

/// A struct representing the options for how to present a view.
public struct PresentationOptions {
    
    public let style: PresentationStyle
    public var onDismiss: (() -> Void)?
    
    public init(style: PresentationStyle, onDismiss: (() -> Void)? = nil) {
        self.style = style
        self.onDismiss = onDismiss
    }
}

/// Represents a style for how a view should be presented.
public enum PresentationStyle {

#if os(macOS)
    case sheet
#else
    @available(iOS 14.0, tvOS 14.0, *)
    case fullScreenCover
    case sheet
#endif

    public static let `default`: PresentationStyle = .sheet
}
