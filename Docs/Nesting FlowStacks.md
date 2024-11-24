# Nesting FlowStacks

Sometimes, it can be useful to break your app's screen flows into several distinct flows of related screens. FlowStacks supports nesting coordinators, though there are some limitations to keep in mind. 

'Coordinator' here is used to describe a view that contains a `FlowStack` to manage a flow of screens. Coordinators are just SwiftUI views, so they can be shown in all the normal ways views can. They can even be pushed onto a parent coordinator's `FlowStack`, allowing you to break out parts of your navigation flow into distinct child coordinators. 

The approach to nesting coordinators will depend on how you are instantiating your `FlowStack`s. A `FlowStack` can be instantiated with either:

1. a binding to a `FlowPath`, which can support any `Hashable` data,
1. a binding to a typed routes array, e.g. `[Route<MyScreen>]`, or
1. no binding at all.

## Approach 1: Nested FlowStack inherits its parent FlowStack's state

If the child FlowStack is instantiated without its own data binding, it can share its parent's data binding as its own source of truth, as long as the parent's data binding is not a typed routes array (since that only supports a single type). In this approach, any type can be pushed onto the path, and as long as somewhere in the stack you have declared how to build a destination for that data type (using the `flowDestination` modifier), the screen will be shown. That means you can nest any number of child `FlowStack`s of this type, and they will all share the same path state - parent and children all have access to the same shared path that includes all coordinators' screens. That means:

- Both parent and child can push new routes onto the path, and the parent's path will include the ones its child has pushed.
- Calling `goBackToRoot` from the child will go all the way back to the parent's root screen.
- The parent is responsible for whether the child should be shown with navigation or not.


## Approach 2: Nested FlowStack holds its own state and takes over navigation duties from its parent FlowStack

If the child has its own data binding (i.e., a `FlowPath` or typed routes array), or its parent FlowStack holds a typed routes array, it's still possible to nest cooordinators, but there are some things to keep in mind. Since only `MyScreen` routes can be added to the array, any nested child `FlowStack`s cannot share the same path state. They will instead have their own independent array of routes. When doing so, it is essential that the child coordinator is always at the top of the parent's routes stack, as it will take over responsibility for pushing and presenting new screens. Otherwise, the parent might attempt to push screen(s) when the child is already pushing screen(s), causing a conflict. 

That means:

- Only the child can push new routes onto the path: it assumes responsibility for navigation until it is removed from its parent's path.
- Calling `goBackToRoot` from the child will go back to the child's root screen.
- The child is responsible for whether its root should be shown with navigation or not.
