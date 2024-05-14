import SwiftUI

/// Builds a view given optional data and a function for transforming the data into a view.
struct ConditionalViewBuilder<Data, DestinationView: View>: View {
  @Binding var data: Data?
  var buildView: (Data) -> DestinationView

  var body: some View {
    if let data {
      buildView(data)
    }
  }
}
