import SwiftUI
import FlowStacks

struct ParentCoordinator: View {

  enum Screen {
    case home
    case childFlowOne
    case childFlowTwo
  }

	@State var routes: Routes<Screen> = [.root(.home)]

  var body: some View {
    Router($routes) { screen, _ in
      switch screen {
      case .home:
        ContainerCoordinatorHomeView(
          goToFlowOne: { routes.presentCover(.childFlowOne) },
          goToFlowTwo: { routes.presentCover(.childFlowTwo) }
        )
      case .childFlowOne:
        ChildFlowCoordinator(flowTitle: "Flow 1", completeFlow: {
          completeFlow()
        })
      case .childFlowTwo:
        ChildFlowCoordinator(flowTitle: "Flow 2", completeFlow: {
          completeFlow()
        })
      }
    }
  }

  private func completeFlow() {
    Task { @MainActor in
      await $routes.withDelaysIfUnsupported {
        $0.goBackToRoot()
      }
    }
  }
}

struct ContainerCoordinatorHomeView: View {

  let goToFlowOne: () -> Void
  let goToFlowTwo: () -> Void

  var body: some View {
    VStack {
      Button("Go to flow one", action: goToFlowOne).padding()
      Button("Go to flow two", action: goToFlowTwo)
    }
  }
}

struct ChildFlowCoordinator: View {

  enum Screen {
    case first
    case second
  }

  let flowTitle: String
  let completeFlow: () -> Void

  @State var routes: Routes<Screen> = [.root(.first)]

  var body: some View {
    Router($routes) { screen, _ in
      switch screen {
      case .first:
        ChildFlowFirstView(
          title: (flowTitle + ": " + "Flow's First Step"),
          closeFlow: closeFlow,
          goToFlowsSecondStep: { routes.presentSheet(.second) }
        )
      case .second:
        ChildFlowSecondView(
          title: (flowTitle + ": " + "Flow's Second Step"),
          closeFlow: closeFlow,
          goBackToCurrentFlowRoot: goBackToCurrentFlowRoot
        )
      }
    }
  }

  private func closeFlow() {
    Task { @MainActor in
      await $routes.withDelaysIfUnsupported {
        $0.goBackToRoot()
      }
      completeFlow()
    }
  }

  private func goBackToCurrentFlowRoot() {
    Task { @MainActor in
      await $routes.withDelaysIfUnsupported {
        $0.goBackToRoot()
      }
    }
  }
}

struct ChildFlowSecondView: View {

  let title: String
  let closeFlow: () -> Void
  let goBackToCurrentFlowRoot: () -> Void

  var body: some View {
    VStack {
      Text(title).font(.headline).padding()
      Button("Go back to start of flow", action: goBackToCurrentFlowRoot).padding()
      Button("Close Flow", action: closeFlow)
    }
  }
}

struct ChildFlowFirstView: View {

  let title: String
  let closeFlow: () -> Void
  let goToFlowsSecondStep: () -> Void

  var body: some View {
    VStack {
      Text(title).font(.headline).padding()
      Button("Go to flow's second view", action: goToFlowsSecondStep).padding()
      Button("Close Flow", action: closeFlow)
    }
  }
}
