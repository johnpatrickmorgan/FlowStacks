import FlowStacks
import SwiftUI

@main
struct FlowStacksApp: App {
  enum Tab: Hashable {
    case numberFlow
    case emojiFlow
    case arrayBinding
  }
  
  @State var selectedTab: Tab = .numberFlow
  
  var body: some Scene {
    WindowGroup {
      TabView(selection: $selectedTab) {
        NumberFlow()
          .tabItem { Text("Numbers") }
          .tag(Tab.numberFlow)
        EmojiFlow()
          .tabItem { Text("Emoji") }
          .tag(Tab.emojiFlow)
        ArrayBindingFlow()
          .tabItem { Text("Array") }
          .tag(Tab.arrayBinding)
      }.onOpenURL { url in
        guard let deeplink = Deeplink(url: url) else { return }
        follow(deeplink)
      }
    }
  }
  
  private func follow(_ deeplink: Deeplink) {
    // Test deeplinks from CLI with, e.g.:
    // `xcrun simctl openurl booted flowstacksapp://numbers/42/13`
    switch deeplink {
    case .numberFlow:
      selectedTab = .numberFlow
    }
  }
}
