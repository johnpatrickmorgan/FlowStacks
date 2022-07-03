import Foundation
import SwiftUI

struct Backport<Content> {
	let content: Content
}

extension View {
	var backport: Backport<Self> { Backport(content: self) }
}
