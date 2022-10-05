# FlowStacks

*FlowStacks* gives you SwiftUI's `NavigationStack` APIs but with superpowers:

🦸 Allows you to manage sheet and full-screen cover presentation as well as push navigation.<br/>
🦸 Provides a `FlowNavigator` environment object to easily push, pop, present etc. from deep in your view hierarchy.<br/>
🦸 Supports older versions of SwiftUI.<br/>

Just replace `Navigation` with `Flow` in the familiar Navigation APIs to start using FlowStacks:

🔀 NavigationStack -> FlowStack<br/>
🔀 NavigationLink -> FlowLink<br/>
🔀 NavigationPath -> FlowPath<br/>
🔀 navigationDestination -> flowDestination<br/>
🔀 NavigationPath.CodableRepresentation -> FlowPath.CodableRepresentation<br/>

You might like this library if:

✅ You want to be able support deeplinks into deeply nested navigation routes in your app.<br/>
✅ You want to be able to easily reuse views within different navigation contexts.<br/>
✅ You want to easily go back to the root screen or a specific screen in the navigation stack.<br/>
✅ You want to use the coordinator pattern to keep navigation logic in a single place.<br/>
✅ You want to break an app's navigation into multiple reusable flows and compose them together.<br/>


## Usage

As with the navigation APIs, a `FlowStack` can be instantiated with a binding to an `Array`, a `FlowPath`, or no binding at all:

```swift
import FlowStacks
import SwiftUI

struct EmojiFlow: View {

  var body: some View {
    FlowStack {
      HomeView()
        .flowDestination(for: NumberList.self, destination: { numberList in
          NumberListView(numberList: numberList)
        })
        .flowDestination(for: Int.self, destination: { number in
          NumberView(number: number)
        })
        .flowDestination(for: String.self, destination: { text in
          Text(text)
        })
    }
  }
}

// Home

private struct HomeView: View {
  @EnvironmentObject var navigator: FlowPathNavigator

  var body: some View {
    VStack(spacing: 8) {
      FlowLink(NumberList(range: 0 ..< 100), style: .push) {
        Text("Pick a number")
      }
    }.navigationTitle("Home")
  }
}

// NumberList

struct NumberList: Hashable, Codable {
  let range: Range<Int>
}

private struct NumberListView: View {
  let numberList: NumberList
  
  var body: some View {
    List {
      ForEach(numberList.range, id: \.self) { number in
        FlowLink(number, style: .sheet(withNavigation: true)) {
          Text("\(number)")
        }
      }
    }.navigationTitle("List")
  }
}

// Number

private struct NumberView: View {
  @EnvironmentObject var navigator: FlowPathNavigator
  @State var number: Int

  var body: some View {
    VStack(spacing: 8) {
      Text("\(number)").font(.title)
      FlowLink(
        number + 1,
        style: .push,
        label: { Text("Show next number") }
      )
      FlowLink(
        Array(repeating: "🐑", count: number).joined(),
        style: .push,
        label: { Text("Visualise with sheep") }
      )
      Button("Go back to root") {
        navigator.goBackToRoot()
      }
    }.navigationTitle("\(number)")
  }
}
```

### Convenience methods

Whether you're interacting with an Array, a FlowPath or a FlowNavigator, a number of convenience methods are available for common transformations, such as:

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

† _Pass `withNavigation: true` if you want to be able to push screens from the presented screen._

### Path automatically updated

If the user taps the back button, the path/array will be automatically updated to reflect the new navigation state. Navigating back with an edge swipe gesture or via a long-press gesture on the back button will also update the routes array automatically, as will swiping to dismiss a sheet.

### Making complex navigation updates

SwiftUI does not allow more than one screen to be pushed, presented or dismissed within a single update. This makes it tricky to make large updates to the navigation state, e.g. when deeplinking straight to a view deep in the navigation hierarchy, when going back several presentation layers to the root, or when restoring arbitrary navigation state. With *FlowStacks*, you can wrap such changes within a call to `withDelaysIfUnsupported`, and the library will break down the large update into a series of smaller updates that SwiftUI supports:

```swift
navigator.withDelaysIfUnsupported {
  $0.goBackToRoot()
}
```

Or, if using a view model:

```swift
viewModel.withDelaysIfUnsupported(\.path) {
  $0.push(...)
  $0.push(...)
  $0.presentSheet(...)
}
```

## Using The Composable Architecture?

See [TCACoordinators](https://github.com/johnpatrickmorgan/TCACoordinators) which uses FlowStacks to help navigation in TCA.
