import SwiftUI

@main
struct FlowStacksApp: App {
  enum Tab: Hashable {
    case numberCoordinator
    case flowPath
    case arrayBinding
    case noBinding
    case viewModel
  }

  @State var selectedTab: Tab = .numberCoordinator

  var body: some Scene {
    WindowGroup {
      TabView(selection: $selectedTab) {
        NumberCoordinator()
          .tabItem { Text("Numbers") }
          .tag(Tab.numberCoordinator)
        FlowPathView()
          .tabItem { Text("FlowPath") }
          .tag(Tab.flowPath)
        ArrayBindingView()
          .tabItem { Text("ArrayBinding") }
          .tag(Tab.arrayBinding)
        NoBindingView()
          .tabItem { Text("NoBinding") }
          .tag(Tab.noBinding)
        NumberVMFlow(viewModel: .init(initialNumber: 64))
          .tabItem { Text("ViewModel") }
          .tag(Tab.viewModel)
      }
      .onOpenURL { url in
        guard let deeplink = Deeplink(url: url) else { return }
        follow(deeplink)
      }
      .useNavigationStack(ProcessArguments.navigationStackPolicy)
    }
  }

  private func follow(_ deeplink: Deeplink) {
    // Test deeplinks from CLI with, e.g.:
    // `xcrun simctl openurl booted flowstacksapp://numbers/42/13`
    switch deeplink {
    case .numberCoordinator:
      selectedTab = .numberCoordinator
    case .viewModelTab:
      selectedTab = .viewModel
    }
  }
}
