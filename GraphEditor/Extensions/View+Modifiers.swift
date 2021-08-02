import SwiftUI

extension View {
  /// The radius to use when drawing rounded corners for the view background.
  func cornerRadius(_ radius: CGFloat) -> some View {
    clipShape(RoundedRectangle.init(cornerRadius: radius, style: .circular))
  }
  
  /// Applies the default box shadow for the patch nodes.
  func patchShadow() -> some View {
    shadow(color: Color(hex: 0x000, alpha: 0.2), radius: 4, x: 0, y: 2)
  }
  
  /// Adds an rounded rectangle overlay to the view.
  func roundedBorder(radius: CGFloat, hidden: Bool = false, color: Color) -> some View {
    overlay(RoundedRectangle(cornerRadius: radius).stroke(color, lineWidth: hidden ? 0 : 2))
  }
  
  /// Applies the given transform if the given condition evaluates to `true`.
  /// - parameter condition: The condition to evaluate.
  /// - parameter transform: The transform to apply to the source `View`.
  /// - returns: Either the original `View` or the modified `View` if the condition is `true`.
  @ViewBuilder
  func when<C: View>(_ condition: Bool, transform: (Self) -> C) -> some View {
    if condition {
        transform(self)
      } else {
        self
      }
    }
}
