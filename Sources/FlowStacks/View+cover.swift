import Foundation
import SwiftUI

extension Backport where Content: View {

	/// A shim for presenting a full-screen cover that falls back on a sheet presentation on platforms
	/// where fullScreenCover is unavailable.
	@ViewBuilder
	func cover<Content: View>(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content contentBuilder: @escaping () -> Content) -> some View {
	  #if os(macOS)
		self
		  content.sheet(
			isPresented: isPresented,
			onDismiss: onDismiss,
			content: content
		  )
	  #else
		if #available(iOS 14.0, tvOS 14.0, macOS 99.9, *) {
			content.fullScreenCover(
			  isPresented: isPresented,
			  onDismiss: onDismiss,
			  content: contentBuilder
			)
		} else {
			content.sheet(
			  isPresented: isPresented,
			  onDismiss: onDismiss,
			  content: contentBuilder
			)
		}
	  #endif
	}

	  /// NOTE: On iOS 14.4 and below, a bug prevented multiple sheet/fullScreenCover modifiers being chained
	  /// on the same view, so we conditionally add the sheet/cover modifiers as a workaround. See
	  /// https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-14_5-release-notes
	  @ViewBuilder
	  func present<Content: View>(asSheet: Bool, isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder content contentBuilder: @escaping () -> Content) -> some View {
		  if asSheet {
			if #available(iOS 14.5, *) {
				content.sheet(
					isPresented: isPresented,
					onDismiss: nil,
					content: contentBuilder
				)
			} else {
				content.background(
					EmptyView()
						.sheet(
							isPresented: isPresented,
							onDismiss: nil,
							content: contentBuilder
						)
				)
			}
		  } else {
			  cover(
				isPresented: isPresented,
				onDismiss: nil,
				content: contentBuilder
			  )
		  }
	  }
}

