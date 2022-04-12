# FlowStacks
_Coordinator pattern in SwiftUI_

*FlowStacks* allow you to manage complex SwiftUI navigation and presentation flows with a simple array. This makes it easy to hoist navigation state into a higher-level coordinator, allowing you to write isolated views that have zero knowledge of their context within the navigation flow of an app. 

You might like this library if:

✅ You want to be able support deeplinks into deeply nested navigation routes in your app.<br/>
✅ You want to be able to easily reuse views within different navigation contexts.<br/>
✅ You want to easily go back to the root screen or a specific screen in the navigation stack.<br/>
✅ You want to use the coordinator pattern to keep navigation logic in a single place.<br/>
✅ You want to break an app's navigation into multiple reusable coordinators and compose them together.<br/>


The library works by translating the array of screens into a hierarchy of nested NavigationLinks and presentation calls, so:

🚫 It does not rely on UIKit at all.<br/>
🚫 It does not use `AnyView` to type-erase screens.<br/>
🚫 It does not try to recreate NavigationView from scratch.<br/>


## Usage

To begin, create an enum encompassing each of the screens your flow might contain, e.g.:

```swift
enum Screen {
  case home
  case numberList
  case numberDetail(Int)
}
```

A coordinator view can then manage an array of `Route<Screen>`s, representing a stack of these screens, each one either pushed or presented. In the body of the coordinator view, initialize a `Router` with a binding to the routes array, and a `ViewBuilder` closure. The closure builds a view for a given screen, e.g.:

```swift
struct AppCoordinator: View {
  @State var routes: Routes<Screen> = [.root(.home)]
    
  var body: some View {
    Router($routes) { screen, _ in
      switch screen {
      case .home:
        HomeView(onGoTapped: showNumberList)
      case .numberList:
        NumberListView(onNumberSelected: showNumber, cancel: goBack)
      case .numberDetail(let number):
        NumberDetailView(number: number, cancel: goBackToRoot)
      }
    }
  }
    
  private func showNumberList() {
    routes.presentSheet(.numberList, embedInNavigationView: true)
  }
    
  private func showNumber(_ number: Int) {
    routes.push(.numberDetail(number))
  }
    
  private func goBack() {
    routes.goBack()
  }
    
  private func goBackToRoot() {
    routes.goBackToRoot()
  }
}
```

### Convenience methods

The routes array can be managed using normal Array methods, but a number of convenience methods are available for common transformations, such as:

| Method       | Effect                                            |
|--------------|---------------------------------------------------|
| push         | Pushes a new screen onto the stack.               |
| presentSheet | Presents a new screen as a sheet.†                |
| presentCover | Presents a new screen as a full-screen cover.†    |
| goBack       | Goes back one screen in the stack.                |
| goBackToRoot | Goes back to the very first screen in the stack.  |
| goBackTo     | Goes back to a specific screen in the stack.      |
| pop          | Pops the current screen if it was pushed.         |
| dismiss      | Dismisses the most recently presented screen.     |

† _Pass `embedInNavigationView: true` if you want to be able to push screens from the presented screen._

### Routes array automatically updated

If the user taps the back button, the routes array will be automatically updated to reflect the new navigation state. Navigating back with an edge swipe gesture or via a long-press gesture on the back button will also update the routes array automatically, as will swiping to dismiss a sheet.

### Bindings

The Router can be configured to work with a binding to the screen state, rather than just a read-only value - just add `$` before the screen argument in the view-builder closure. The screen itself can then be responsible for updating its state within the routes array. Normally an enum is used to represent the screen, so it might be necessary to further extract the associated value for a particular screen as a binding. You can do that using the [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library, which includes a number of helpful Binding transformations for optional and enum state, e.g.:

```swift
import SwiftUINavigation

struct BindingExampleCoordinator: View {
  enum Screen {
    case start
    case number(Int)
  }
  
  @State var routes: Routes<Screen> = [.root(.start, embedInNavigationView: true)]
    
  var body: some View {
    Router($routes) { $screen, _ in
      if let number = Binding(unwrapping: $screen, case: /Screen.number) {
        // Here number is a Binding<Int>, so EditableNumberView can change its
        // value in the routes array.
        EditableNumberView(number: number)
      } else {
        StartView(goTapped: goTapped)
      }
    }
  }
  
  func goTapped() {
    routes.push(.number(42))
  }
}
```

### Child coordinators

Coordinators are just views themselves, so they can be presented, pushed, added to a `TabView` or a `WindowGroup`, and can be configured in all the normal ways views can. They can even be pushed onto a parent coordinator's navigation stack, allowing you to break out parts of your navigation flow into separate child coordinators. When doing so, it is best that the child coordinator is always at the top of the parent's routes stack, as it will take over responsibility for pushing and presenting new screens. Otherwise, the parent might attempt to push screen(s) when the child is already pushing screen(s), causing a conflict.

### Using View Models

Using `Router`s in the coordinator pattern also works well when using View Models. In these cases, the navigation state can live in the coordinator's own view model, and the Screen enum can include each screen's view model. With view models, the first example above can be re-written:

```swift
enum Screen {
  case home(HomeViewModel)
  case numberList(NumberListViewModel)
  case numberDetail(NumberDetailViewModel)
}

class AppCoordinatorViewModel: ObservableObject {
  @Published var routes: Routes<Screen>
    
  init() {
    self.routes = [.root(.home(.init(onGoTapped: showNumberList)))]
  }
    
  func showNumberList() {
    routes.presentSheet(.numberList(.init(onNumberSelected: showNumber, cancel: goBack)), embedInNavigationView: true)
  }
    
  func showNumber(_ number: Int) {
    routes.push(.numberDetail(.init(number: number, cancel: goBackToRoot)))
  }
    
  func goBack() {
    routes.goBack()
  }
    
  func goBackToRoot() {
    routes.goBackToRoot()
  }
}

struct AppCoordinator: View {
  @ObservedObject var viewModel: AppCoordinatorViewModel
    
  var body: some View {
    Router($viewModel.routes) { screen in
      switch screen {
      case .home(let viewModel):
        HomeView(viewModel: viewModel)
      case .numberList(let viewModel):
        NumberListView(viewModel: viewModel)
      case .number(let viewModel):
        NumberView(viewModel: viewModel)
      }
    }
  }
}
```

### Making complex navigation updates

SwiftUI does not allow more than one screen to be pushed, presented or dismissed within a single update. This makes it tricky to make large updates to the navigation state, e.g. when deeplinking straight to a view deep in the navigation hierarchy, when going back several presentation layers to the root, or when restoring arbitrary navigation state. With *FlowStacks*, you can wrap such changes within a call to `withDelaysIfUnsupported`, and the library will break down the large update into a series of smaller updates that SwiftUI supports:

```swift
$routes.withDelaysIfUnsupported {
  $0.goBackToRoot()
}
```

Or, if using a view model:

```swift
RouteSteps.withDelaysIfUnsupported(self, \.routes) {
  $0.push(...)
  $0.push(...)
  $0.presentSheet(...)
}
```

### Fixed root screen

Often the root screen in a screen flow is static - always the same screen is in the root position. In this case you can use the `showing` function on the root screen view to simplify matters. It takes the same parameters as the `Router` initializer:

```swift
struct ShowingCoordinator: View {
  enum Screen {
    case detail, edit, confirm
  }
  
  @State var routes: Routes<Screen> = []
  
  var body: some View {
    HomeView(onGoTapped: { routes.presentSheet(.detail) })
      .showing($routes) { $number, index in
        ...
      }
  }
}
```

## How does it work? 

This [blog post](https://johnpatrickmorgan.github.io/2021/07/03/NStack/) outlines how an array of screens can be translated into a hierarchy of views and `NavigationLink`s. `Router` uses a similar approach to allow both navigation and presentation.

## Caveats

Currently only the `.stack` navigation view style is supported. There are some unexpected behaviours with the `.column` navigation view style that make it problematic for the approach used in this library.

Be careful that your screens do not inadvertently end up observing the navigation state, e.g. if you were to pass a coordinator object to its screens as an `ObservableObject` or `EnvironmentObject`. Not only would that cause your screens to be re-rendered unnecessarily whenever the navigation state changes, it can also cause SwiftUI's navigation state to deviate from your app's state. 

## Using The Composable Architecture?

See [TCACoordinators](https://github.com/johnpatrickmorgan/TCACoordinators) which uses FlowStacks to help navigation in TCA.
