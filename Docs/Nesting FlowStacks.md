# Nesting FlowStacks

Sometimes, it can be useful to break your app's screen flows into several distinct flows of related screens. FlowStacks supports nesting coordinators ('coordinator' is used to describe a view that contains a `FlowStack` to manage a flow of screens). 

Coordinators are just SwiftUI views, so they can be shown in all the normal ways views can. They can even be pushed onto a parent coordinator's `FlowStack`, allowing you to break out parts of your navigation flow into distinct child coordinators. 

The best approach to nesting coordinators will depend on how you are instantiating your `FlowStack`. A `FlowStack` can be instantiated with either:

1. a binding to a `FlowPath`,
1. no binding at all, or
1. a binding to a routes array, e.g. `[Route<MyScreen>]`.


## Nesting FlowStacks using FlowPaths

In the first two cases, any type can be pushed onto the path, and as long as somewhere in the stack you have declared how to build a flow destination for that data type (using the `flowDestination` modifier), the screen will be shown. That means you can nest any number of child `FlowStack`s of this type, and they will all share the same path state - parent and children all have access to the same shared path that includes all coordinators' screens. See the [example app](FlowStacksApp/Shared/FlowPathView) for how this might work.

## Nesting FlowStacks using Routes Arrays

'If using a binding to a routes array, e.g. `[Route<MyScreen>]`, it's still possible to nest cooordinators, but there are some things to keep in mind. Since only `MyScreen` routes can be added to the array, any nested child `FlowStack`s cannot share the same path state. They will instead have their own independent array of routes. When doing so, it is essential that the child coordinator is always at the top of the parent's routes stack, as it will take over responsibility for pushing and presenting new screens. Otherwise, the parent might attempt to push screen(s) when the child is already pushing screen(s), causing a conflict.
