import Foundation
import SwiftUI

public extension View {
  func flowDestination<D: Hashable, C: View>(for dataType: D.Type, @ViewBuilder destination builder: @escaping (D) -> C) -> some View {
    return modifier(DestinationBuilderModifier(typedDestinationBuilder: { AnyView(builder($0)) }))
  }
}

public extension View {
  /// Associates a destination view with a binding that can be used to show
  /// the view within a ``FlowStack``.
  ///
  /// In general, favor binding a path to a flow stack for programmatic
  /// navigation. Add this view modifer to a view inside a ``FlowStack``
  /// to programmatically push a single view onto the stack. This is useful
  /// for building components that can push an associated view. For example,
  /// you can present a `ColorDetail` view for a particular color:
  ///
  ///     @State private var showDetails = false
  ///     var favoriteColor: Color
  ///
  ///     FlowStack {
  ///         VStack {
  ///             Circle()
  ///                 .fill(favoriteColor)
  ///             Button("Show details") {
  ///                 showDetails = true
  ///             }
  ///         }
  ///         .flowDestination(isPresented: $showDetails, style: .sheet) {
  ///             ColorDetail(color: favoriteColor)
  ///         }
  ///         .nbNavigationTitle("My Favorite Color")
  ///     }
  ///
  /// Do not put a navigation destination modifier inside a "lazy" container,
  /// like ``List`` or ``LazyVStack``. These containers create child views
  /// only when needed to render on screen. Add the navigation destination
  /// modifier outside these containers so that the navigation stack can
  /// always see the destination.
  ///
  /// - Parameters:
  ///   - isPresented: A binding to a Boolean value that indicates whether
  ///     `destination` is currently presented.
  ///   - destination: A view to present.
  func flowDestination<V>(isPresented: Binding<Bool>, style: RouteStyle, @ViewBuilder destination: () -> V) -> some View where V: View {
    let builtDestination = AnyView(destination())
    return modifier(
      LocalDestinationBuilderModifier(
        isPresented: isPresented,
        routeStyle: style,
        builder: { builtDestination }
      )
    )
  }
}

public extension View {
  /// Associates a destination view with a bound value for use within a
  /// ``FlowStack``.
  ///
  /// Add this view modifer to a view inside a ``FlowStack`` to describe
  /// the view that the flow stack displays when presenting a particular kind of data. Programmatically
  /// update the binding to display or remove the view. For example:
  ///
  /// ```
  ///    @State private var colorShown: Color?
  ///
  ///    FlowStack(withNavigation: false) {
  ///      List {
  ///        Button("Red") { colorShown = .red }
  ///        Button("Pink") { colorShown = .pink }
  ///        Button("Green") { colorShown = .green }
  ///      }
  ///      .flowDestination(item: $colorShown, style: .sheet) { color in
  ///        Text(String(describing: color))
  ///      }
  ///    }
  /// ```
  ///
  /// When the person using the app taps on the Red button, the red color
  /// is pushed onto the navigation stack. You can pop the view
  /// by setting `colorShown` back to `nil`.
  ///
  /// You can add more than one navigation destination modifier to the stack
  /// if it needs to present more than one kind of data.
  ///
  /// Do not put a navigation destination modifier inside a "lazy" container,
  /// like ``List`` or ``LazyVStack``. These containers create child views
  /// only when needed to render on screen. Add the navigation destination
  /// modifier outside these containers so that the navigation view can
  /// always see the destination.
  ///
  /// - Parameters:
  ///   - item: A binding to the data presented, or `nil` if nothing is
  ///     currently presented.
  ///   - style: The route style, e.g. sheet, cover, push.
  ///   - destination: A view builder that defines a view to display
  ///     when `item` is not `nil`.
  func flowDestination<D: Hashable, C: View>(item: Binding<D?>, style: RouteStyle, @ViewBuilder destination: @escaping (D) -> C) -> some View {
    flowDestination(
      isPresented: Binding(
        get: { item.wrappedValue != nil },
        set: { isActive, transaction in
          if !isActive {
            item.transaction(transaction).wrappedValue = nil
          }
        }
      ),
      style: style,
      destination: { ConditionalViewBuilder(data: item, buildView: destination) }
    )
  }
}
