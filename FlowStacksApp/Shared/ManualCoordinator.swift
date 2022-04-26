import FlowStacks
import SwiftUI
import SwiftUINavigation

enum ManualScreen: Equatable {
  case details(Int)
  case contactUs
}

struct SideBar: View {
  var pushNative: () -> Void
  var pushManual: () -> Void
  
  var body: some View {
    List {
      Text("Native NavigationView")
        .onTapGesture {
          pushNative()
        }
      Text("Manual Navigation")
        .onTapGesture {
          pushManual()
        }
    }
  }
}

struct ContactUsView: View {
  var goBack: (() -> Void)?
  var body: some View {
    VStack {
      Text("Contact us")
      if let goBack = goBack {
        Button("Back", action: goBack)
      }
    }
  }
}

struct DetailsView: View {
  @Binding var number: Int
  var pushContact: () -> Void
  let presentDoubleCover: (Int) -> Void
  let presentDoubleSheet: (Int) -> Void
  let pushNext: (Int) -> Void
  let goBack: (() -> Void)?
  let goBackToRoot: () -> Void
  let goRandom: (() -> Void)?

  var body: some View {
    VStack {
      NumberView(
        number: $number,
        presentDoubleCover: presentDoubleCover,
        presentDoubleSheet: presentDoubleSheet,
        pushNext: pushNext,
        goBack: goBack,
        goBackToRoot: goBackToRoot,
        goRandom: goRandom
      )
      Button("Contact us", action: pushContact)
    }
  }
}

struct ManualCoordinator: View {
  @State var routes: Routes<ManualScreen> = [.root(.details(0), embedInNavigationView: true)]
  
  var randomRoutes: [Route<ManualScreen>] {
    let options: [[Route<ManualScreen>]] = [
      [.root(.details(0), manualNavigation: true)],
      [
        .root(.details(0), manualNavigation: true),
        .push(.details(1), manualNavigation: true),
        .push(.details(2), manualNavigation: true),
        .push(.details(3), manualNavigation: true),
        .sheet(.details(4), embedInNavigationView: false, manualNavigation: true),
        .push(.details(5), manualNavigation: true)
      ],
      [
        .root(.details(0), manualNavigation: true),
        .push(.details(1), manualNavigation: true),
        .push(.details(2), manualNavigation: true),
        .push(.details(3), manualNavigation: true)
      ],
      [
        .root(.details(0), manualNavigation: true),
        .push(.details(1), manualNavigation: true),
        .sheet(.details(2), embedInNavigationView: false, manualNavigation: true),
        .push(.details(3), manualNavigation: true),
        .sheet(.details(4), embedInNavigationView: true),
        .push(.details(5))
      ],
      [
        .root(.details(0), manualNavigation: true),
        .sheet(.details(1), embedInNavigationView: true),
        .cover(.details(2), embedInNavigationView: true),
        .push(.details(3)),
        .sheet(.details(4), embedInNavigationView: true),
        .push(.details(5))
      ]
    ]
    return options.randomElement()!
  }
  
  var body: some View {
    HStack {
      SideBar(
        pushNative: {
          routes = [.root(.details(0), embedInNavigationView: true)]
        },
        pushManual: {
          routes = [.root(.details(0), manualNavigation: true)]
        }
      ).frame(width: 300)
      VStack {
        Router($routes) { $screen, index in
          switch screen {
          case .details:
            if let number = Binding(unwrapping: $screen, case: /ManualScreen.details) {
              DetailsView(
                number: number,
                pushContact: {
                  routes.push(.contactUs)
                },
                presentDoubleCover: { number in
                  #if os(macOS)
                  routes.presentSheet(.details(number * 2), manualNavigation: true)
                  #else
                  routes.presentSheet(.details(number * 2), embedInNavigationView: true)
                  #endif
                },
                presentDoubleSheet: { number in
                  #if os(macOS)
                  routes.presentSheet(.details(number * 2), manualNavigation: true)
                  #else
                  routes.presentSheet(.details(number * 2), embedInNavigationView: true)
                  #endif
                },
                pushNext: { number in
                  routes.push(.details(number + 1))
                },
                goBack: index != 0 ? { routes.goBack() } : nil,
                goBackToRoot: {
                  $routes.withDelaysIfUnsupported {
                    $0.goBackToRoot()
                  }
                },
                goRandom: {
                  $routes.withDelaysIfUnsupported {
                    $0 = randomRoutes
                  }
                }
              )
            }
          case .contactUs:
            ContactUsView(goBack: index != 0 ? { routes.goBack() } : nil)
          }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }
}

struct ManualCoordinator_Previews: PreviewProvider {
  static var previews: some View {
    ManualCoordinator()
  }
}
