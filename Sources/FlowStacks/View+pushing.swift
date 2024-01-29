//
//  File.swift
//
//
//  Created by John Morgan on 16/01/2024.
//

import Foundation
import SwiftUI

struct PushingModifier<Destination: View>: ViewModifier {
  @Binding var isActiveBinding: Bool
  var destination: Destination
  
  func body(content: Content) -> some View {
    content
      .background(
        NavigationLink(
          destination: destination,
          isActive: $isActiveBinding,
          label: EmptyView.init
        )
          .hidden()
      )
  }
}

extension View {
  func pushing<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(PushingModifier(isActiveBinding: isActive, destination: destination))
  }
}
