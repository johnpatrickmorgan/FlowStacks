import Foundation
import SwiftUI

/// A view that manages state for presenting and pushing screens..
public struct FlowStack<Root: View, Data: Hashable, NavigationViewModifier: ViewModifier>: View {
  var withNavigation: Bool
  var dataType: FlowStackDataType
  var navigationViewModifier: NavigationViewModifier
  @Environment(\.flowStackDataType) var parentFlowStackDataType
  @Environment(\.nestingIndex) var nestingIndex
  @EnvironmentObject var routesHolder: RoutesHolder
  @EnvironmentObject var inheritedDestinationBuilder: DestinationBuilderHolder
  @Binding var externalTypedPath: [Route<Data>]
  @State var internalTypedPath: [Route<Data>] = []
  @StateObject var path = RoutesHolder()
  @StateObject var destinationBuilder = DestinationBuilderHolder()
  var root: Root
  var useInternalTypedPath: Bool

  var deferToParentFlowStack: Bool {
    (parentFlowStackDataType == .flowPath || parentFlowStackDataType == .noBinding) && dataType == .noBinding
  }

  var screenModifier: some ViewModifier {
    ScreenModifier(
      path: path,
      destinationBuilder: parentFlowStackDataType == nil ? destinationBuilder : inheritedDestinationBuilder,
      navigator: FlowNavigator(useInternalTypedPath ? $internalTypedPath : $externalTypedPath),
      typedPath: useInternalTypedPath ? $internalTypedPath : $externalTypedPath,
      nestingIndex: (nestingIndex ?? 0) + 1
    )
  }

  public var body: some View {
    if deferToParentFlowStack {
      root
    } else {
      Router(rootView: root.environment(\.routeIndex, -1), navigationViewModifier: navigationViewModifier, screenModifier: screenModifier, screens: $path.boundRoutes)
        .modifier(EmbedModifier(withNavigation: withNavigation && parentFlowStackDataType == nil, navigationViewModifier: navigationViewModifier))
        .modifier(screenModifier)
        .environment(\.flowStackDataType, dataType)
        .onFirstAppear {
          path.routes = externalTypedPath.map { $0.erased() }
        }
    }
  }

  init(routes: Binding<[Route<Data>]>?, withNavigation: Bool = false, navigationViewModifier: NavigationViewModifier, dataType: FlowStackDataType, @ViewBuilder root: () -> Root) {
    _externalTypedPath = routes ?? .constant([])
    self.root = root()
    self.withNavigation = withNavigation
    self.navigationViewModifier = navigationViewModifier
    self.dataType = dataType
    useInternalTypedPath = routes == nil
  }

  /// Initialises a ``FlowStack`` with a binding to an Array of routes.
  /// - Parameters:
  ///   - routes: The array of routes that will manage navigation state.
  ///   - withNavigation: Whether the root view should be wrapped in a navigation view.
  ///   - navigationViewModifier: A modifier for styling any navigation views the FlowStack creates.
  ///   - root: The root view for the ``FlowStack``.
  public init(_ routes: Binding<[Route<Data>]>, withNavigation: Bool = false, navigationViewModifier: NavigationViewModifier, @ViewBuilder root: () -> Root) {
    self.init(routes: routes, withNavigation: withNavigation, navigationViewModifier: navigationViewModifier, dataType: .typedArray, root: root)
  }
}

public extension FlowStack where Data == AnyHashable {
  /// Initialises a ``FlowStack`` without any binding - the stack of routes will be managed internally by the ``FlowStack``.
  /// - Parameters:
  ///   - withNavigation: Whether the root view should be wrapped in a navigation view.
  ///   - navigationViewModifier: A modifier for styling any navigation views the FlowStack creates.
  ///   - root: The root view for the ``FlowStack``.
  init(withNavigation: Bool = false, navigationViewModifier: NavigationViewModifier, @ViewBuilder root: () -> Root) {
    self.init(routes: nil, withNavigation: withNavigation, navigationViewModifier: navigationViewModifier, dataType: .noBinding, root: root)
  }

  /// Initialises a ``FlowStack`` with a binding to a ``FlowPath``.
  /// - Parameters:
  ///   - path: The FlowPath that will manage navigation state.
  ///   - withNavigation: Whether the root view should be wrapped in a navigation view.
  ///   - navigationViewModifier: A modifier for styling any navigation views the FlowStack creates.
  ///   - root: The root view for the ``FlowStack``.
  init(_ path: Binding<FlowPath>, withNavigation: Bool = false, navigationViewModifier: NavigationViewModifier, @ViewBuilder root: () -> Root) {
    let path = Binding(
      get: { path.wrappedValue.routes },
      set: { path.wrappedValue.routes = $0 }
    )
    self.init(routes: path, withNavigation: withNavigation, navigationViewModifier: navigationViewModifier, dataType: .flowPath, root: root)
  }
}

public extension FlowStack where NavigationViewModifier == UnchangedViewModifier {
  /// Initialises a ``FlowStack`` with a binding to an Array of routes.
  /// - Parameters:
  ///   - routes: The array of routes that will manage navigation state.
  ///   - withNavigation: Whether the root view should be wrapped in a navigation view.
  ///   - root: The root view for the ``FlowStack``.
  init(_ routes: Binding<[Route<Data>]>, withNavigation: Bool = false, @ViewBuilder root: () -> Root) {
    self.init(routes: routes, withNavigation: withNavigation, navigationViewModifier: UnchangedViewModifier(), dataType: .typedArray, root: root)
  }
}

public extension FlowStack where NavigationViewModifier == UnchangedViewModifier, Data == AnyHashable {
  /// Initialises a ``FlowStack`` without any binding - the stack of routes will be managed internally by the ``FlowStack``.
  /// - Parameters:
  ///   - withNavigation: Whether the root view should be wrapped in a navigation view.
  ///   - root: The root view for the ``FlowStack``.
  init(withNavigation: Bool = false, @ViewBuilder root: () -> Root) {
    self.init(withNavigation: withNavigation, navigationViewModifier: UnchangedViewModifier(), root: root)
  }

  /// Initialises a ``FlowStack`` with a binding to a ``FlowPath``.
  /// - Parameters:
  ///   - path: The FlowPath that will manage navigation state.
  ///   - withNavigation: Whether the root view should be wrapped in a navigation view.
  ///   - root: The root view for the ``FlowStack``.
  init(_ path: Binding<FlowPath>, withNavigation: Bool = false, @ViewBuilder root: () -> Root) {
    self.init(path, withNavigation: withNavigation, navigationViewModifier: UnchangedViewModifier(), root: root)
  }
}
