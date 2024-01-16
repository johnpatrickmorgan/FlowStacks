//
//  File.swift
//  
//
//  Created by John Morgan on 16/01/2024.
//

import Foundation
import SwiftUI

struct FullScreenCoverModifier<Destination: View>: ViewModifier {
  @Binding var isActiveBinding: Bool
  var destination: Destination

  func body(content: Content) -> some View {
    content
      .cover(
        isPresented: $isActiveBinding,
        onDismiss: nil,
        content: { destination }
      )
  }
}

extension View {
  func fullScreenCover<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(FullScreenCoverModifier(isActiveBinding: isActive, destination: destination))
  }
}
