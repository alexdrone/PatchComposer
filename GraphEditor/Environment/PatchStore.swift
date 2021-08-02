import SwiftUI

class PatchStore: ObservableObject {
  @Published var nodes: [PatchNode] = []
  @Published var selectedNodeID: Int?
  @Published var selectedConnection: PatchConnection? = nil
  var connections: [PatchSocketID: [PatchConnection]] { nodes.connections }
  var delegate: PatchEditorDelegate?
  
  // MARK: - Mutations
  
  func add(originID: PatchSocketID, destinationID: PatchSocketID) {
    assert(Thread.isMainThread)
    guard let (origin, _) = findSocketPair(
      originID: originID,
      destinationID: destinationID)
    else {
      // Could not find the sockets with the given IDs.
      return
    }
    guard
      !connections.values.flatMap({ $0 }).map({ $0.destinationID }).contains(destinationID)
    else {
      // The socket has already an attached stream.
      return
    }
    let connection = PatchConnection(originID: originID, destinationID: destinationID)
    guard delegate?.shouldAddConnection(connection) ?? true else {
      // The connection is not available.
      return
    }
    if origin.connections.contains(where: { $0.destinationID == destinationID }) { return }
    origin.addConnection(destinationID: destinationID)
    delegate?.didChangePatchNodes(nodes)
    objectWillChange.send()
  }
  
  func remove(originID: PatchSocketID, destinationID: PatchSocketID) {
    assert(Thread.isMainThread)
    guard let (origin, _) = findSocketPair(
      originID: originID,
      destinationID: destinationID)
    else {
      // Could not find the sockets with the given IDs.
      return
    }
    origin.connections = origin.connections.filter { $0.destinationID != destinationID }
    delegate?.didChangePatchNodes(nodes)
    objectWillChange.send()
  }
  
  @discardableResult
  func rename(originID: PatchSocketID, name: String) -> Bool {
    assert(Thread.isMainThread)
    let allOutputSockets = nodes.flatMap { $0.outputs }
    guard let socket = allOutputSockets.filter({ $0.id == originID }).first else {
      // Could not find the output socket with the given ID.
      return false
    }
    let names = Set<String>(allOutputSockets.compactMap { $0.name })
    guard !names.contains(name) else {
      // Names must me unique.
      return false
    }
    socket.name = name
    delegate?.didChangePatchNodes(nodes)
    objectWillChange.send()
    return true
  }
  
  func streamName(originID: PatchSocketID) -> String? {
    assert(Thread.isMainThread)
    guard let socket = nodes.flatMap({ $0.outputs }).filter({ $0.id == originID }).first else {
      return nil
    }
    return socket.name
  }
  
  func remove(node: PatchNode) {
    assert(Thread.isMainThread)
    for socket in node.outputs where !socket.connections.isEmpty {
      let originID = socket.id
      for destinationID in socket.connections {
        remove(originID: originID, destinationID: destinationID.destinationID)
      }
    }
    for (originID, destinations) in connections {
      for destination in destinations.filter({ $0.destinationID.nodeID == node.id }) {
        remove(originID: originID, destinationID: destination.destinationID)
      }
    }
    nodes = nodes.filter { $0.id != node.id }
    delegate?.didChangePatchNodes(nodes)
    objectWillChange.send()
  }
  
  func remove(socket: PatchSocket) {
    assert(Thread.isMainThread)
    guard let socketNode = nodes.first(where: { $0.id == socket.id.nodeID }) else {
      // Could not find the node with the given index.
      return
    }
    for node in nodes {
      for output in node.outputs {
        output.connections = output.connections.filter { $0.destinationID != socket.id }
      }
    }
    socketNode.inputs = socketNode.inputs.filter { $0.id != socket.id }
    socketNode.outputs = socketNode.outputs.filter { $0.id != socket.id }
    self.delegate?.didChangePatchNodes(self.nodes)
    self.objectWillChange.send()
  }
  
  
  // MARK: - Private
  
  private func findSocketPair(
    originID: PatchSocketID,
    destinationID: PatchSocketID
  ) -> (PatchSocket, PatchSocket)? {
    assert(Thread.isMainThread)
    let allInputSocket = nodes.flatMap { $0.inputs }
    let allOutputSockets = nodes.flatMap { $0.outputs }
    guard
      let origin = allOutputSockets.first(where: { $0.id == originID }),
      let destination = allInputSocket.first(where: { $0.id == destinationID })
    else {
      return nil
    }
    return (origin, destination)
  }
  
  // MARK: - Prompts
  
  func showRenamePrompt(originID: PatchSocketID) {
    NSAppModalTextField(title: Locale.renameTitle, prompt: Locale.renamePrompt) {
      guard let name = $0?.replacingOccurrences(of: ":", with: "") else { return }
      if !self.rename(originID: originID, name: name) {
        NSAppModalAlert(title: Locale.renameTitle, prompt: Locale.renameFailed)
      }
    }
  }
  
  func showRenamePrompt(node: PatchNode) {
    NSAppModalTextField(title: Locale.renameNodeTitle, prompt: Locale.renameNodePrompt) {
      guard let name = $0?.replacingOccurrences(of: ":", with: "") else { return }
      node.name = name
      self.delegate?.didChangePatchNodes(self.nodes)
      self.objectWillChange.send()
    }
  }
  
  func showAddStreamPrompt(node: PatchNode) {
    let values = [
      PatchSocketID.StreamType.input.rawValue,
      PatchSocketID.StreamType.output.rawValue
    ]
    NSAppModalTextFieldAndComboBox(
      title: Locale.addStreamTitle,
      prompt: Locale.addStreamPrompt,
      defaultValue: PatchSocketID.StreamType.input.rawValue,
      values: values) {
        assert(Thread.isMainThread)
        guard
          let rawValue = $0,
          let type = PatchSocketID.StreamType(rawValue: rawValue)
        else {
          return
        }
        let separator: String = ":"
        var tag: String? = $1.isEmpty ? nil : $1
        var index: Int? = nil
        if $1.contains(separator) {
          tag = $1.components(separatedBy:separator).first!
          index = Int($1.components(separatedBy: separator).last ?? "")
        }
        var id: PatchSocketID!
        if let tag = tag {
          id = PatchSocketID(nodeID: node.id, type: type, tag: tag, index: index)
        } else {
          let lastIndex = (type == .input ? node.inputs : node.outputs).reduce(-1) {
            guard $1.id.tag == nil else { return $0 }
            return max($0, $1.id.index!)
          }
          id = PatchSocketID(nodeID: node.id, type: type, index: lastIndex + 1)
        }
        let socket = PatchSocket(id: id)
        if (type == .input) {
          node.inputs.append(socket)
        } else {
          node.outputs.append(socket)
        }
        self.delegate?.didChangePatchNodes(self.nodes)
        self.objectWillChange.send()
      }
  }
}
