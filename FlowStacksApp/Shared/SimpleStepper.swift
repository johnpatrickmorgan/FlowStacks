import SwiftUI

struct SimpleStepper: View {
  @Binding var number: Int

  var body: some View {
    #if os(tvOS)
      HStack {
        Text("\(number)")
        Button("-") { number -= 1 }.buttonStyle(.plain)
        Button("+") { number += 1 }.buttonStyle(.plain)
      }
    #else
      Stepper(label: { Text("\(number)").font(.body) }, onIncrement: { number += 1 }, onDecrement: { number -= 1 })
        .fixedSize()
    #endif
  }
}
