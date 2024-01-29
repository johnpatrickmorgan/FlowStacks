//
//  File.swift
//  
//
//  Created by John Morgan on 16/01/2024.
//

import Foundation
import SwiftUI

struct PresentingModifier<Destination: View>: ViewModifier {
  @Binding var sheetBinding: Bool
  @Binding var coverBinding: Bool
  var destination: Destination
  var onDismiss: (() -> Void)?

  func body(content: Content) -> some View {
    /// NOTE: On iOS 14.4 and below, a bug prevented multiple sheet/fullScreenCover modifiers being chained
    /// on the same view, so we conditionally add the sheet/cover modifiers as a workaround. See
    /// https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-14_5-release-notes
    if #available(iOS 14.5, *) {
      content
        .sheet(
          isPresented: $sheetBinding,
          onDismiss: onDismiss,
          content: { destination }
        )
        .cover(
          isPresented: $coverBinding,
          onDismiss: onDismiss,
          content: { destination }
        )
      
    } else {
      if sheetBinding {
        content
          .sheet(
            isPresented: $sheetBinding,
            onDismiss: onDismiss,
            content: { destination }
          )
      } else {
        content
          .cover(
            isPresented: $coverBinding,
            onDismiss: onDismiss,
            content: { destination }
          )
      }
    }
  }
}

extension View {
  func presenting<Destination: View>(sheetBinding: Binding<Bool>, coverBinding: Binding<Bool>, destination: Destination, onDismiss: (() -> Void)?) -> some View {
    return modifier(PresentingModifier(sheetBinding: sheetBinding, coverBinding: coverBinding, destination: destination, onDismiss: onDismiss))
  }
}
