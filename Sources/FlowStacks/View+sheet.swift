//
//  File.swift
//  
//
//  Created by John Morgan on 16/01/2024.
//

import Foundation
import SwiftUI

struct SheetModifier<Destination: View>: ViewModifier {
  @Binding var isActiveBinding: Bool
  var destination: Destination

  func body(content: Content) -> some View {
    content
      .sheet(isPresented: $isActiveBinding, onDismiss: nil, content: {
        destination
      })
  }
}

extension View {
  func sheet<Destination: View>(isActive: Binding<Bool>, destination: Destination) -> some View {
    return modifier(SheetModifier(isActiveBinding: isActive, destination: destination))
  }
}
