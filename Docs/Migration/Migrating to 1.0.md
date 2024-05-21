# Migrating to 1.0

Before its API was brought more in line with `NavigationStack` APIs, previous versions of `FlowStacks` had two major differences:

- Previously the `Router` (now the `FlowStack`) handled both state management _and_ building destination views. The latter has now been decoupled into a separate function `flowDestination(...)`. This gives you more control over where you set up flow destinations, but for easy migration, you can keep them in the same place.
- Previously the root screen was part of the routes array. The root screen is no longer part of the routes array, which might be awkward if your flow required you to swap out the root screen. In those cases, you will probably want to split the flow into two separate flows, each with its own FlowStack and a parent view that switches between them as needed.
  
Here's an example migration:

<details>
 <summary>Previous API</summary>

```swift
enum Screen {
  case home
  case numberList
  case numberDetail(Int)
}

struct AppCoordinator: View {
  @State var routes: Routes<Screen> = [.root(.home)]
    
  var body: some View {
    Router($routes, embedInNavigationView: true) { screen, _ in
      switch screen {
      case .home:
        HomeView()
      case .numberList:
        NumberListView()
      case .numberDetail(let number):
        NumberDetailView(number: number)
      }
    }
  }
}
```

</details>

<details>
 <summary>New API</summary>

```swift
enum Screen {
  case numberList
  case numberDetail(Int)
}

struct AppCoordinator: View {
  @State var routes: [Route<Screen>] = []
    
  var body: some View {
    FlowStack($routes, withNavigation: true) { 
      HomeView()
        .flowDestination(for: Screen.self) { screen in
          switch screen {
          case .numberList:
            NumberListView()
          case .numberDetail(let number):
            NumberDetailView(number: number)
        }
    }
  }
}
```

</details>
