import SwiftUI

struct PatchLine: View {
  let fromID: PatchSocketID
  let toID: PatchSocketID?
  var to: CGPoint = .zero
  
  @State private var highlighted: Bool = false
  
  init(fromID: PatchSocketID, toID: PatchSocketID) {
    self.fromID = fromID
    self.toID = toID
  }
  
  init(fromID: PatchSocketID, to: CGPoint) {
    self.fromID = fromID
    self.toID = nil
    self.to = to
  }
  
  @Environment(\.patchStyle) var style: PatchStyle
  @EnvironmentObject private var store: PatchStore
  @EnvironmentObject private var geometry: PatchMeshGeometry
  
  private var patchConnection: PatchConnection? {
    guard let toID = toID else { return nil }
    return PatchConnection(originID: fromID, destinationID: toID)
  }
  private var isConnectionSelected: Bool {
    store.selectedConnection == patchConnection
  }

  var body: some View {
    ZStack {
      path
    }
  }
  
  private var path: some View {
    let fromPoint = geometry.point(for: fromID) ?? .zero
    let toPoint = geometry.point(for: toID) ?? to
    return PatchPath(
      from:fromPoint,
      to: toPoint,
      bounce: highlighted ? Constants.bounceMultiplier : Constants.idleBounceMultiplier)
      .stroke(isConnectionSelected ? style.selected : style.foreground, lineWidth: 4)
      .shadow(color: Color(hex: 0x000, alpha: 0.4), radius: 4, x: 0, y: 2)
      .contextMenu { contextMenu }
      .onTapGesture {
        store.selectedConnection = isConnectionSelected ? nil : patchConnection
        withAnimation(animation) {
          highlighted = isConnectionSelected
        }
      }
  }
  
  @ViewBuilder
  private var contextMenu: some View {
    if let toID = toID {
      Button(Locale.delete) { store.remove(originID: fromID, destinationID: toID) }
    }
    Button(Locale.rename) { store.showRenamePrompt(originID: fromID) }
  }
  
  private var animation: Animation {
    .interpolatingSpring(stiffness: 10, damping: 1, initialVelocity: 1)
  }
}

private struct PatchPath: Shape {
  let from: CGPoint
  let to: CGPoint
  var bounce: CGFloat
  
  var animatableData: CGFloat {
    get { bounce }
    set { bounce = newValue }
  }
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: from)
    
    var f = 0.3
    if (to.x > from.x) { f = 0.15 }
    if (abs(to.x - from.x) < Constants.straightLinePathThreshold) { f = 0.05 }
  
    let m = CGPoint(x: (to.x + from.x) * 0.5 , y: (to.y + from.y) * 0.5)
    let c1 = CGPoint(x: (f * m.x + from.x) * bounce , y: from.y * bounce)
    let c2 = CGPoint(x: (to.x - f * m.x) * bounce, y: to.y * bounce)

    path.addCurve(to: to, control1: c1, control2: c2)
    return path
  }
}

private enum Constants {
  static let straightLinePathThreshold: CGFloat = 150
  static let idleBounceMultiplier: CGFloat = 1.0
  static let bounceMultiplier: CGFloat = 1.05
}
