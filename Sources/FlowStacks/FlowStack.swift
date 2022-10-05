import Foundation
import SwiftUI

public struct FlowStack<Root: View, Data: Hashable>: View {
  let withNavigation: Bool
  var unownedPath: Binding<[Route<Data>]>?
  @State var ownedPath: [Route<Data>] = []
  @StateObject var destinationBuilder = DestinationBuilderHolder()
  var root: Root

  var path: Binding<[Route<Data>]> {
    unownedPath ?? $ownedPath
  }

  var erasedPath: Binding<[Route<AnyHashable>]> {
    return Binding(
      get: { path.wrappedValue.map { $0.map { $0 } } },
      set: { newValue in
        path.wrappedValue = newValue.map {
          $0.map { screen in
            guard let data = screen as? Data else {
              fatalError("Cannot add \(type(of: screen)) to stack of \(Data.self)")
            }
            return data
          }
        }
      }
    )
  }

  public var body: some View {
    NavigationView {
      Router(rootView: root, screens: path)
    }.navigationViewStyle(supportedNavigationViewStyle)
      .environmentObject(PathHolder(erasedPath))
      .environmentObject(destinationBuilder)
      .environmentObject(FlowNavigator(path))
  }

  public init(_ path: Binding<[Route<Data>]>?, withNavigation: Bool = false, @ViewBuilder root: () -> Root) {
    self.unownedPath = path
    self.withNavigation = withNavigation
    self.root = root()
  }
}

public extension FlowStack where Data == AnyHashable {
  init(withNavigation: Bool = false, @ViewBuilder root: () -> Root) {
    self.init(nil, withNavigation: withNavigation, root: root)
  }
}

public extension FlowStack where Data == AnyHashable {
  init(_ path: Binding<FlowPath>, withNavigation: Bool = false, @ViewBuilder root: () -> Root) {
    let erasedPath = Binding(
      get: {
        path.wrappedValue.elements
      },
      set: {
        path.wrappedValue.elements = $0
      }
    )
    self.init(erasedPath, withNavigation: withNavigation, root: root)
  }
}
