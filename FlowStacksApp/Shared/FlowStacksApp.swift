import SwiftUI

@main
struct FlowStacksApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        ParentCoordinator()
          .tabItem { Text("Parent") }
        NumberCoordinator()
          .tabItem { Text("Numbers") }
        VMCoordinator()
          .tabItem { Text("VMs") }
        BindingCoordinator()
          .tabItem { Text("Binding") }
        ShowingCoordinator()
          .tabItem { Text("Showing") }
      }
    }
  }
}
