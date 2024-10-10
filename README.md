# FlowStacks

This package takes SwiftUI's familiar and powerful `NavigationStack` API and gives it superpowers, allowing you to use the same API not just for push navigation, but also for presenting sheets and full-screen covers. And because it's implemented using the navigation APIs available in older SwiftUI versions, you can even use it on earlier versions of iOS, tvOS, watchOS and macOS.

You might like this library if:

✅ You want to support deeplinks into deeply nested navigation routes in your app.<br/>
✅ You want to easily re-use views within different navigation contexts.<br/>
✅ You want to easily go back to the root screen or a specific screen in the navigation stack.<br/>
✅ You want to use the coordinator pattern to keep navigation logic in a single place.<br/>
✅ You want to break an app's navigation into multiple reusable coordinators and compose them together.<br/>

### Familiar APIs

If you already know SwiftUI's `NavigationStack` APIs, `FlowStacks` should feel familiar and intuitive. Just replace 'Navigation' with 'Flow' in type and function names:
 
✅ `NavigationStack` -> `FlowStack`

✅ `NavigationLink` -> `FlowLink`

✅ `NavigationPath` -> `FlowPath`

✅ `navigationDestination` -> `flowDestination`

`NavigationStack`'s full API is replicated, so you can initialise a `FlowStack` with a binding to an `Array`, with a binding to a `FlowPath`, or with no binding at all. The only difference is that the array should be a `[Route<MyScreen>]`s instead of `[MyScreen]`. The `Route` enum combines the destination data with info about what style of presentation is used. Similarly, when you create a `FlowLink`, you must additionally specify the route style, e.g. `.push`, `.sheet` or `.cover`. As with `NavigationStack`, if the user taps the back button or swipes to dismiss a sheet, the routes array will be automatically updated to reflect the new navigation state. 

## Example

<details>
  <summary>Click to expand an example</summary>

```swift
import FlowStacks
import SwiftUI

struct ContentView: View {
  @State var path = FlowPath()
  @State var isShowingWelcome = false

  var body: some View {
    FlowStack($path, withNavigation: true) {
      HomeView()
        .flowDestination(for: Int.self, destination: { number in
          NumberView(number: number)
        })
        .flowDestination(for: String.self, destination: { text in
          Text(text)
        })
        .flowDestination(isPresented: $isShowingWelcome, style: .sheet) {
          Text("Welcome to FlowStacks!")
        }
    }
  }
}

struct HomeView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  
  var body: some View {
    List {
      ForEach(0 ..< 10, id: \.self) { number in
        FlowLink(value: number, style: .sheet(withNavigation: true), label: { Text("Show \(number)") })
      }
      Button("Show 'hello'") {
        navigator.push("Hello")
      }
    }
    .navigationTitle("Home")
  }
}

struct NumberView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  let number: Int

  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)")
      FlowLink(
        value: number + 1,
        style: .push,
        label: { Text("Show next number") }
      )
      Button("Go back to root") {
        navigator.goBackToRoot()
      }
    }
    .navigationTitle("\(number)")
  }
}
```

</details>

## Additional features

As well as replicating the standard features of the new `NavigationStack` APIs, some helpful utilities have also been added. 

### FlowNavigator

A `FlowNavigator` object is available through the environment, giving access to the current routes array and the ability to update it via a number of convenience methods. The navigator can be accessed via the environment, e.g. for a `FlowPath`-backed stack:

```swift
@EnvironmentObject var navigator: FlowPathNavigator
```

Or for a FlowStack backed by a routes array, e.g. `[Route<ScreenType>]`:

```swift
@EnvironmentObject var navigator: FlowNavigator<ScreenType>
```

Here's an example of a `FlowNavigator` in use:

```swift
@EnvironmentObject var navigator: FlowNavigator<ScreenType>

var body: some View {
  VStack {
    Button("View detail") {
      navigator.push(.detail)
    }
    Button("Go back to profile") {
      navigator.goBackTo(.profile)
    }
    Button("Go back to root") {
      navigator.goBackToRoot()
    }
  }
}
```

### Convenience methods

When interacting with a `FlowNavigator` (and also the original `FlowPath` or routes array), a number of convenience methods are available for easier navigation, including:

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

_† Pass `embedInNavigationView: true` if you want to be able to push screens from the presented screen._

### Deep-linking
 
 Before the `NavigationStack` APIs were introduced, SwiftUI did not support pushing more than one screen in a single state update, e.g. when deep-linking to a screen multiple layers deep in a navigation hierarchy. *FlowStacks* works around this limitation: you can make any such changes, and the library will, behind the scenes, break down the larger update into a series of smaller updates that SwiftUI supports, with delays if necessary in between.

### Bindings

The flow destination can be configured to work with a binding to its screen state in the routes array, rather than just a read-only value - just add `$` before the screen argument in the `flowDestination` function's view-builder closure. The screen itself can then be responsible for updating its state within the routes array, e.g.:

```swift
import SwiftUINavigation

struct BindingExampleCoordinator: View {
  @State var path = FlowPath()
    
  var body: some View {
    FlowStack($path, withNavigation: true) {
      FlowLink(value: 1, style: .push, label: { Text("Push '1'") })
        .flowDestination(for: Int.self) { $number in
          EditNumberScreen(number: $number) // This screen can now change the number stored in the path.
        }
    }
  }
```

 If you're using a typed Array of routes, you're probably using an enum to represent the screen, so it might be necessary to further extract the associated value for a particular case of that enum as a binding. You can do that using the [SwiftUINavigation](https://github.com/pointfreeco/swiftui-navigation) library, which includes a number of helpful Binding transformations for optional and enum state, e.g.:



<details>
  <summary>Click to expand an example of using a Binding to a value in a typed Array of enum-based routes</summary>
  
```swift
import FlowStacks
import SwiftUI
import SwiftUINavigation

enum Screen: Hashable {
  case number(Int)
  case greeting(String)
}

struct BindingExampleCoordinator: View {
  @State var routes: Routes<Screen> = []

  var body: some View {
    FlowStack($routes, withNavigation: true) {
      HomeView()
        .flowDestination(for: Screen.self) { $screen in
          if let number = Binding(unwrapping: $screen, case: /Screen.number) {
            // Here `number` is a `Binding<Int>`, so `EditNumberScreen` can change its
            // value in the routes array.
            EditNumberScreen(number: number)
          } else if case let .greeting(greetingText) = screen {
            // Here `greetingText` is a plain `String`, as a binding is not needed.
            Text(greetingText)
          }
        }
    }
  }
}

struct HomeView: View {
  @EnvironmentObject var navigator: FlowPathNavigator

  var body: some View {
    VStack {
      FlowLink(value: Screen.number(42), style: .push, label: { Text("Show Number") })
      FlowLink(value: Screen.greeting("Hello world"), style: .push, label: { Text("Show Greeting") })
    }
  }
}

struct EditNumberScreen: View {
  @Binding var number: Int

  var body: some View {
    Stepper(
      label: { Text("\(number)") },
      onIncrement: { number += 1 },
      onDecrement: { number -= 1 }
    )
  }
}

```
</details>

### Child flow coordinators

`FlowStack`s are designed to be composable, so that you can have multiple flow coordinators, each with its own `FlowStack`, and you can present or push a child coordinator from a parent. See [Nesting FlowStacks](Docs/Nesting%20FlowStacks.md) for more info.

## How does it work? 

The library works by translating the array of routes into a hierarchy of nested NavigationLinks and presentation calls, expanding on the technique used in [NavigationBackport](https://github.com/johnpatrickmorgan/NavigationBackport).

## Migrating from earlier versions

Please see the [migration docs](Docs/Migration/Migrating%20to%201.0.md).

-------

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T114GWOT)

