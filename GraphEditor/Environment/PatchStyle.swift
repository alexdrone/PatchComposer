import AppKit
import SwiftUI

extension EnvironmentValues {
  public var patchStyle: PatchStyle {
    get { self[PatchStyleKey.self] }
    set { self[PatchStyleKey.self] = newValue }
  }
}

private struct PatchStyleKey: EnvironmentKey {
  typealias Value = PatchStyle
  static var defaultValue: PatchStyle = DefaultPatchStyle()
  static let style: String = "PatchStyleKey"
}

public protocol PatchStyle {
  var grid: Color { get }
  var background: LinearGradient { get }
  var header: LinearGradient { get }
  var foreground: Color { get }
  var selected: Color { get }
  var minimumSize: CGSize { get }
  var cornerRadius: CGFloat { get }
}

public struct DefaultPatchStyle: PatchStyle {
  public let grid: Color = Color(hex: 0x3C3C3C)
  public let background: LinearGradient = LinearGradient(
    colors: [Color(hex: 0x2E2F3A), Color(hex: 0x27292B)],
    startPoint: .top,
    endPoint: .bottom)
  public let header: LinearGradient = LinearGradient(
    colors: [Color(hex: 0x5C426F), Color(hex: 0x4E4C76)],
    startPoint: .top,
    endPoint: .bottom)
  public let foreground: Color = Color(hex: 0xFFFFFF)
  public let selected: Color = Color(hex: 0xE78944)
  public let minimumSize: CGSize  = CGSize(width: 256, height: 192)
  public let cornerRadius: CGFloat = 14
}

public struct QuartzComposerPatchStyle: PatchStyle {
  public let grid: Color = Color(hex: 0x3C3C3C)
  public let background: LinearGradient = LinearGradient(
    colors: [Color(hex: 0x691168), Color(hex: 0x5E105D)],
    startPoint: .top,
    endPoint: .bottom)
  public let header: LinearGradient = LinearGradient(
    colors: [Color(hex: 0xA567A4), Color(hex: 0x7B2F7B)],
    startPoint: .top,
    endPoint: .bottom)
  public let foreground: Color = Color(hex: 0xFFFFFF)
  public let selected: Color = Color(hex: 0xFECB4C)
  public let minimumSize: CGSize  = CGSize(width: 256, height: 192)
  public let cornerRadius: CGFloat = 14
}

extension Color {
  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha
    )
  }
}

extension NSColor {
  convenience init(hex: UInt, alpha: CGFloat = 1) {
    self.init(
      red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(hex & 0x0000FF) / 255.0,
      alpha: alpha
    )
  }
}


