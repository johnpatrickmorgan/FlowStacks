import FlowStacks
import SwiftUI
import SwiftUINavigation

enum ManualScreen: Equatable {
    case details(Int)
    case contactUs
}

struct SideBar: View {
    var onTap: (Int) -> Void

    var body: some View {
        List(1...10, id: \.self) { index in
            Text("Item \(index)")
                .onTapGesture {
                    onTap(index)
                }
        }
    }
}

struct ContactUsView: View {
    var body: some View {
        Text("Contact us")
    }
}

struct DetailsView: View {
    var number: Int = 0
    var onTapContact: () -> Void
    var goToNext: (Int) -> Void
    var goBack: () -> Void
    var body: some View {
      VStack {
        Text("Item \(number)")
        Button("Contact us") {
            onTapContact()
        }
        Button("Push next") {
            goToNext(number + 1)
        }
        Button("Go back", action: goBack)
      }
    }
}

struct ManualCoordinator: View {
    @State var routes: Routes<ManualScreen> = [.root(.details(0), embedInNavigationView: false, manualNavigation: true)]

    var body: some View {
        HStack {
            SideBar { index in
                routes = [.root(.details(index), embedInNavigationView: false, manualNavigation: true)]
            }.frame(width: 300)
            Router($routes) { screen, index in
                switch screen {
                case .details(let number):
                    DetailsView(number: number) {
                        routes.push(.contactUs, manualNavigation: true)
                    } goToNext: { newNum in
                        routes.push(.details(newNum), manualNavigation: true)
                    } goBack: {
                      if index != 0 {
                        routes.goBack()
                      }
                    }
                case .contactUs:
                    ContactUsView()
                }
            }.frame(maxWidth: .infinity)
        }
    }
}

struct ManualCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        ManualCoordinator()
    }
}
