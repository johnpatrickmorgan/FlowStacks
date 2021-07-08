# NStack

An NStack allows you to manage SwiftUI navigation state with a single stack property. This makes it easy to hoist that state into a high-level view, such as a coordinator. The coordinator pattern allows you to write isolated views that have zero knowledge of their context within the navigation flow of an app.

## Usage

To begin, create an enum encompassing each of the screens the navigation stack might contain, e.g.:

```swift
enum Screen {
    case home
    case numberList
    case numberDetail(Int)
}
```

You can then add a stack of these screens as a single property in a coordinator view. In the body of the coordinator view, return a `NavigationView` containing an `NStack`. The `NStack` should be initialized with a binding to the stack, and a `ViewBuilder` closure. The closure builds a view from a given screen, e.g.:

```swift
struct AppCoordinator: View {
    @State var stack = Stack<Screen>(root: .home)
    
    var body: some View {
        NavigationView {
            NStack($stack) { screen in
                switch screen {
                case .home:
                    HomeView(onGoTapped: showNumberList)
                case .numberList:
                    NumberListView(onNumberSelected: showNumber, cancel: pop)
                case .numberDetail(let number):
                    NumberDetailView(number: number, cancel: popToRoot)
                }
            }
        }
    }
    
    private func showNumberList() {
        stack.push(.numberList)
    }
    
    private func showNumber(_ number: Int) {
        stack.push(.number(number))
    }
    
    private func pop() {
        stack.pop()
    }
    
    private func popToRoot() {
        stack.popToRoot()
    }
}
```

As you can see, pushing a new view is as easy as `stack.push(...)` and popping can be achieved with `stack.pop()`. There are convenience methods for popping to the root and popping to a specific screen in the stack. 

If the user taps the back button, the stack will be automatically updated to reflect its new state. Navigating back with an edge swipe gesture or long-press gesture on the back button will also update the stack.

Coordinators are just views, so they can be presented, added to a `TabView` or a `WindowGroup`, and can be configured in all the normal ways views can. 

## Child coordinators

As coordinator views are just views, they can even be pushed onto a parent coordinator's navigation stack. When doing so, it is best that the child coordinator is always at the top of the parent's stack, as it will take over responsibility for pushing new views. 

In order to allow coordinators to be nested in this way, the child coordinator should not include its own `NavigationView`. In fact, it's a good idea to add the `NavigationView` as high in the view hierarchy as you can - e.g. at the top-level of the app, when presenting a new coordinator, or when adding one to a `TabView`.

## Using View Models

Using `NStack`s in the coordinator pattern also works well when using View Models. In these cases, the navigation state can live in the coordinator's own view model, and the Screen enum can include each screen's view model. With view models, the example above can be re-written:

```swift
enum Screen {
    case home(HomeViewModel)
    case numberList(NumberListViewModel)
    case numberDetail(NumberDetailViewModel)
}

class AppCoordinatorViewModel: ObservableObject {
    @Published var stack = Stack<Screen>()
    
    init() {
        stack.push(.home(.init(onGoTapped: showNumberList)))
    }
    
    func showNumberList() {
        stack.push(.numberList(.init(onNumberSelected: showNumber, cancel: pop)))
    }
    
    func showNumber(_ number: Int) {
        stack.push(.numberDetail(.init(number: number, cancel: popToRoot)))
    }
    
    func pop() {
        stack.pop()
    }
    
    func popToRoot() {
        stack.popToRoot()
    }
}

struct AppCoordinator: View {
    @ObservedObject var viewModel = AppCoordinatorViewModel()
    
    var body: some View {
        NavigationView {
            NStack($viewModel.stack) { screen in
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
}
```

## Limitations

Currently, SwiftUI does not support increasing the navigation stack by more than one in a single update. The `Stack` object will throw an assertion failure if you try to do so.

## How does it work? 

This [blog post](https://johnpatrickmorgan.github.io/2021/07/03/NStack/) outlines how NStack translates the stack of screens into a hierarchy of views and `NavigationLink`s. 
