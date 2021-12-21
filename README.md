# FlowStacks
_Coordinator pattern in SwiftUI_

*FlowStacks* allow you to manage complex SwiftUI navigation and presentation flows with a single piece of state. This makes it easy to hoist that state into a high-level coordinator view. Using this pattern, you can write isolated views that have zero knowledge of their context within the navigation flow of an app.

## Usage

To begin, create an enum encompassing each of the screens your navigation stack might contain, e.g.:

```swift
enum Screen {
    case home
    case numberList
    case numberDetail(Int)
}
```

A coordinator view can then manage an array of `Route<Screen>`s, representing a stack of screens, each one either pushed or presented. In the body of the coordinator view, initialize an `Router` with a binding to the routes array, and a `ViewBuilder` closure. The closure builds a view for a given screen, e.g.:

```swift
struct AppCoordinator: View {
    @State var routes: Routes<Screen> = [.root(.home)]
    
    var body: some View {
            Router($routes) { screen, _ in
                switch screen {
                case .home:
                    HomeView(onGoTapped: showNumberList)
                case .numberList:
                    NumberListView(onNumberSelected: showNumber, cancel: pop)
                case .numberDetail(let number):
                    NumberDetailView(number: number, cancel: goBackToRoot)
                }
            }
    }
    
    private func showNumberList() {
        routes.push(.numberList)
    }
    
    private func showNumber(_ number: Int) {
        routes.presentSheet(.number(number), embedInNavigationView: true)
    }
    
    private func pop() {
        routes.pop()
    }
    
    private func goBackToRoot() {
        routes.goBackToRoot()
    }
}
```

As you can see, pushing a new view is as easy as `routes.push(...)` and presenting can be achieved with `routes.presentSheet(...)` or `routes.presentCover(...)`. There are convenience methods for going back to the root (`routes.goBackToRoot()`) and going back to a specific screen in the flow (`routes.goBackTo(.home)`). 

If the user taps the back button, the routes will be automatically updated to reflect its new state. Navigating back with an edge swipe gesture or long-press gesture on the back button will also update the routes array.

Coordinators are just views, so they can be presented, pushed, added to a `TabView` or a `WindowGroup`, and can be configured in all the normal ways views can.

## Child coordinators

As coordinator views are just views, they can even be pushed onto a parent coordinator's navigation stack. When doing so, it is best that the child coordinator is always at the top of the parent's routes stack, as it will take over responsibility for pushing new views. 

In order to allow coordinators to be nested in this way, the child coordinator should not embed its root view in a `NavigationView`. In fact, it's a good idea to add the `NavigationView` as high in the view hierarchy as you can - e.g. at the top-level of the app, when presenting a new coordinator, or when adding one to a `TabView`.

## Using View Models

Using `Router`s in the coordinator pattern also works well when using View Models. In these cases, the navigation state can live in the coordinator's own view model, and the Screen enum can include each screen's view model. With view models, the example above can be re-written:

```swift
enum Screen {
    case home(HomeViewModel)
    case numberList(NumberListViewModel)
    case numberDetail(NumberDetailViewModel)
}

class AppCoordinatorViewModel: ObservableObject {
    @Published var routes: Routes<Screen>
    
    init() {
        routes = [.root(.home(.init(onGoTapped: showNumberList)))]
    }
    
    func showNumberList() {
        routes.push(.numberList(.init(onNumberSelected: showNumber, cancel: goBack)))
    }
    
    func showNumber(_ number: Int) {
        routes.presentSheet(.numberDetail(.init(number: number, cancel: goBackToRoot)))
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

## Large updates

SwiftUI does not allow more than one screen to be pushed, presented or dismissed in a single update. This makes it tricky to make larger updates to the navigation state, e.g. when deeplinking to a view deep in the navigation hierarchy, or restoring navigation state etc. With this library, you can make such changes within a call to `withDelaysIfUnsupported`, and the library will break down the large update into a series of smaller updates that SwiftUI will allow:

```swift
$routes.withDelaysIfUnsupported {
  $0.goBackToRoot()
}
```

## How does it work? 

This [blog post](https://johnpatrickmorgan.github.io/2021/07/03/NStack/) outlines how an `NStack` translates the stack of screens into a hierarchy of views and `NavigationLink`s. `Router` uses a similar approach to allow both pushing and presenting.

## Caveats

Be careful that your screens do not inadvertently end up observing the coordinator's navigation state, e.g. if you were to pass a coordinator object to its screens as an `ObservableObject` or `EnvironmentObject`. Not only would that cause your screens to be re-rendered unnecessarily whenever the navigation state changes, it can also cause SwiftUI's navigation state to deviate from your app's state. 

## Using The Composable Architecture?

See [TCACoordinators](https://github.com/johnpatrickmorgan/TCACoordinators) which uses FlowStacks to help navigation in TCA.
