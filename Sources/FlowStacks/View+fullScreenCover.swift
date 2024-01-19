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
  #if os(macOS)
    content
        .sheet(
          isPresented: $isActiveBinding,
          onDismiss: nil,
          content: { destination }
        )
  #else
      if #available(iOS 14.0, tvOS 14.0, macOS 99.9, *) {
        content
          .fullScreenCover(
            isPresented: $isActiveBinding,
            onDismiss: nil,
            content: { destination }
          )
      } else {
        content
          .sheet(
            isPresented: $isActiveBinding,
            onDismiss: nil,
            content: { destination }
          )
      }
  #endif
  }
}

extension View {
  func fullScreenCover<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(FullScreenCoverModifier(isActiveBinding: isActive, destination: destination))
  }
}
