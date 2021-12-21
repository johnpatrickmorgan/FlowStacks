import SwiftUI

@main
struct FlowStacksApp: App {
    var body: some Scene {
        WindowGroup {
          TabView {
            MixedCoordinator()
              .tabItem { Text("Mixed") }
            VMPCoordinator()
              .tabItem { Text("VM") }
          }
        }
    }
}
