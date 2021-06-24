# NStack

An NStack allows you to hoist SwiftUI navigation state into a higher-level coordinator view. The coordinator pattern allows you to write isolated views that have zero knowledge of their context within the navigation flow of an app.


```swift
enum Screen: Hashable {
    
    case home
    case numbers
    case number(Int)
}

struct AppNavigator: View {
    
    @State var stack: [Screen] = [.home]
    
    var body: some View {
        NStack(stack: $stack) { screen in
            switch screen {
            case .home:
                HomeView(showNumbers: showNumbers)
            case .numbers:
                NumbersView(showNumber: showNumber, pop: pop)
            case .number(let number):
                NumberView(number: number, pop: pop)
            }
        }
    }
    
    private func showNumbers() {
        stack.append(.numbers)
    }
    
    private func showNumber(_ number: Int) {
        stack.append(.number(number))
    }
    
    private func pop() {
        stack = stack.dropLast()
    }
}
```
