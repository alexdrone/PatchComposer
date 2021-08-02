import SwiftUI

struct PatchText: View {
  private let text: String
  private let bold: Bool
  private let highlighted: Bool

  @Environment(\.patchStyle) var style: PatchStyle
  
  init(_ verbatim: String, bold: Bool = false, highlighted: Bool = false) {
    self.text = verbatim
    self.bold = bold
    self.highlighted = highlighted
  }
  
  var body: some View {
    Text(verbatim: text).patchTextStyle(style: style, bold: bold, highlighted: highlighted)
  }
}

extension Text {
  func patchTextStyle(
    style: PatchStyle,
    bold: Bool = false,
    highlighted: Bool = false
  ) -> some View {
    self
      .font(Font.system(.caption, design: .rounded))
      .fontWeight(bold ? .bold : .regular)
      .foregroundColor(highlighted ? style.selected : style.foreground)
  }
}
