import Foundation
import SwiftUI

public extension Binding where Value: Collection, Value.Element: RouteProtocol {
  
  func withDelaysIfUnsupported<Screen>(_ transform: (inout Array<Route<Screen>>) -> Void) where Value == Array<Route<Screen>> {
    let start = wrappedValue
    let end: [Route<Screen>] = {
      var transformed = start
      transform(&transformed)
      return transformed
    }()
    
    // TODO: make incremental changes to move from initial to transformed in supported steps.
    
    self.wrappedValue = end
  }
}
