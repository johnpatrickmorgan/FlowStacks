import Foundation
import SwiftUI

struct DestinationBuilderView<Data>: View {
  let data: Data
  let index: Int
  let style: RouteStyle

  @EnvironmentObject var destinationBuilder: DestinationBuilderHolder

  var body: some View {
    return destinationBuilder.build(data, index: index, style: style)
  }
}
