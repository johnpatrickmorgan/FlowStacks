import SwiftUI

@main
struct FlowStacksApp: App {
    var body: some Scene {
        WindowGroup {
          TabView {
            NavigationView { NumberNCoordinator() }
              .tabItem { Text("NStack") }
            NumberPCoordinator()
              .tabItem { Text("PStack") }
            MixedCoordinator()
              .tabItem { Text("Mixed") }
            VMPCoordinator()
              .tabItem { Text("VMP") }
          }
        }
    }
}
