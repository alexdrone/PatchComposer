import SwiftUI

final class PatchMeshGeometry: ObservableObject {
  @Published var socketFrames: [PatchSocketID: CGRect] = [:]
  @Published var connectingSocket: (PatchSocketID, CGPoint)?
  @Published var meshContentSize: CGFloat = 0

  func point(for id: PatchSocketID?) -> CGPoint? {
    guard let id = id else { return nil }
    guard let frame = socketFrames[id] else { return .zero }
    let offset: CGFloat = Constants.socketCenterOffset
    return CGPoint(x: frame.origin.x + offset, y: frame.origin.y + offset)
  }
  
  func socketID(for point: CGPoint) -> PatchSocketID? {
    for (id, frame) in socketFrames {
      let targetFrame = frame.insetBy(dx: Constants.socketAnchorDx, dy: Constants.socketAnchorDy)
      let pointFrame = CGRect(origin: point, size: CGSize(width: 1, height: 1))
      if pointFrame.intersects(targetFrame) {
        return id
      }
    }
    return nil
  }
}

struct PatchMesh: View {
  @Environment(\.patchStyle) var style: PatchStyle
  @EnvironmentObject private var store: PatchStore
  @EnvironmentObject private var geometry: PatchMeshGeometry
  
  var body: some View {
    let connections = store.connections
    let origins = Array(connections.keys)
    Group {
      ForEach(origins) { fromID in
        ForEach(connections[fromID]!) { toID in
          PatchLine(fromID: fromID, toID: toID.destinationID)
        }
      }
      if let connectingSocket = geometry.connectingSocket {
        PatchLine(fromID: connectingSocket.0, to: connectingSocket.1)
      }
    }
    .drawingGroup()
  }
}

private enum Constants {
  static let socketCenterOffset: CGFloat = 6
  static let socketAnchorDx: CGFloat = -40
  static let socketAnchorDy: CGFloat = -10
}

