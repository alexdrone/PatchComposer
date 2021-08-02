import SwiftUI

struct PatchInputSocketView: View {
  let node: PatchNode
  let id: PatchSocketID

  @Environment(\.patchStyle) var style: PatchStyle
  @EnvironmentObject private var store: PatchStore
  
  private var socket: PatchSocket {
    node.inputs.first { $0.id == id }!
  }
  private var isConnected: Bool {
    store.connections.values.flatMap { $0 }.map { $0.destinationID }.contains(id)
  }
  
  private var isSelected: Bool {
    guard
      let originID = store.selectedConnection?.originID,
      let destinationID = store.selectedConnection?.destinationID
    else {
      return false
    }
    return originID == id || destinationID == id
  }

  var body: some View {
    HStack(spacing: 0) {
      PatchStocketView(socket: socket, isConnected: isConnected, isSelected: isSelected)
        .padding([.trailing])
      PatchText(socket.id.label)
      Spacer()
    }
    .padding(.leading, Constants.padding)
  }
}

struct PatchOutputSocketView: View {
  let node: PatchNode
  let id: PatchSocketID
  
  @Environment(\.patchStyle) var style: PatchStyle
  @EnvironmentObject private var geometry: PatchMeshGeometry
  @EnvironmentObject private var store: PatchStore

  private var socket: PatchSocket {
    node.outputs.first { $0.id == id }!
  }
  private var isConnected: Bool {
    !socket.connections.isEmpty
  }
  private var isSelected: Bool {
    guard
      let originID = store.selectedConnection?.originID,
      let destinationID = store.selectedConnection?.destinationID
    else {
      return false
    }
    return originID == id || destinationID == id
  }

  var body: some View {
    HStack(spacing: 0) {
      Spacer()
      PatchText(socket.id.label)
      PatchStreamName(socket: socket)
      PatchStocketView(socket: socket, isConnected: isConnected, isSelected: isSelected)
        .padding([.leading])
    }
    .padding(.trailing, Constants.padding)
    .gesture(dragGesture)
  }
  
  private func mouseLocation(dragLocation: CGPoint) -> CGPoint {
    let nsPoint = NSEvent.mouseLocation
    let window = NSApplication.shared.mainWindow?.frame ?? .zero
    let point = CGPoint(
      x: dragLocation.x,
      y: window.size.height - nsPoint.y + window.minY - 30)
    return point
  }
  
  private var dragGesture: some Gesture {
    DragGesture(minimumDistance: 0, coordinateSpace: .named(PatchEditor.coordinateSpace))
      .onChanged {
        NSCursor.crosshair.push()
        let location = mouseLocation(dragLocation: $0.location)
        if let destinationID = geometry.socketID(for: location) {
          geometry.connectingSocket = (id, geometry.point(for: destinationID)!)
        } else {
          geometry.connectingSocket = (id, location)
        }
      }
      .onEnded {
        NSCursor.pop()
        let location = mouseLocation(dragLocation: $0.location)
        geometry.connectingSocket = nil
        if let destinationID = geometry.socketID(for: location) {
          store.add(originID: id, destinationID: destinationID)
        }
      }
  }
}

private struct PatchStocketView: View {
  let socket: PatchSocket
  let isConnected: Bool
  let isSelected: Bool
  
  @Environment(\.patchStyle) var style: PatchStyle
  @EnvironmentObject private var geometry: PatchMeshGeometry
  
  var body: some View {
    GeometryReader { geometryProxy in
      socketView(geometryProxy: geometryProxy)
    }
    .fixedSize()
  }
  
  private func socketView(geometryProxy: GeometryProxy) -> some View {
    let image = Image(systemName: isConnected ? "circle.fill" : "circle")
      .font(.caption.weight(.bold))
      .foregroundColor(isSelected ? style.selected : style.foreground)
    
    DispatchQueue.main.async {
      let coordinateSpace = PatchEditor.coordinateSpace
      let oldValue = self.geometry.socketFrames[socket.id]
      let newValue = geometryProxy.frame(in: .named(coordinateSpace))
      if (oldValue != newValue) {
        self.geometry.socketFrames[socket.id] = geometryProxy.frame(in: .named(coordinateSpace))
      }
    }
    return image
  }
}

private enum Constants {
  static let padding: CGFloat = 4
}
