import Foundation

public struct PatchSocketID: Identifiable, Equatable, Hashable {
  public enum StreamType: String {
    case input
    case output
  }
  
  public let nodeID: Int
  public let type: StreamType
  public let index: Int?
  public let tag: String?
  
  public init(nodeID: Int, type: StreamType, tag: String, index: Int? = nil) {
    self.nodeID = nodeID
    self.type = type
    self.tag = tag
    self.index = index
  }
  
  public init(nodeID: Int, type: StreamType, index: Int) {
    self.nodeID = nodeID
    self.type = type
    self.tag = nil
    self.index = index
  }
  
  /// Returns the name of this socket.
  public var label: String {
    var components: [String] = []
    if let tag = tag {
      components.append(tag)
    }
    if let index = index {
      components.append(String(index))
    }
    return components.joined(separator: ":")
  }
  
  /// Return the unique identifier for this socket.
  public var id: String { "\(nodeID)__\(type)__\(label)".replacingOccurrences(of: ":", with: "_") }
  
  public static func == (lhs: PatchSocketID, rhs: PatchSocketID) -> Bool { lhs.id == rhs.id }
}

/// Represents a input or output socket for a patch node.
public final class PatchSocket: Identifiable, Equatable {
  /// Synthesized stable key for this object.
  public let id: PatchSocketID
  /// Optional name (applicable only to output sockets).
  public var name: String
  
  var connections: [PatchConnection]
  
  init(id: PatchSocketID, connections: [PatchConnection] = [], name: String? = nil) {
    self.id = id
    self.connections = connections
    self.name = name ?? PatchSocket.newName()
  }
  
  @discardableResult
  public func addConnection(destinationID: PatchSocketID, name: String? = nil) -> PatchSocket {
    let connection = PatchConnection(
      originID: id,
      destinationID: destinationID)
    connections.append(connection)
    return self
  }
  
  /// Adds a connection to one of the inputs sockets for the specified node.
  @discardableResult
  public func addConnection(nodeID: Int, index: Int) -> PatchSocket {
    let connection = PatchConnection(
      originID: id,
      destinationID: PatchSocketID(nodeID: nodeID, type: .input, index: index))
    connections.append(connection)
    return self
  }
  
  /// Adds a connection to one of the inputs sockets for the specified node with the given tag.
  @discardableResult
  public func addConnection(
    nodeID: Int,
    tag: String,
    index: Int? = nil,
    name: String? = nil
  ) -> PatchSocket {
    let connection = PatchConnection(
      originID: id,
      destinationID: PatchSocketID(nodeID: nodeID, type: .input, tag: tag, index: index))
    connections.append(connection)
    return self
  }
  
  public static func == (lhs: PatchSocket, rhs: PatchSocket) -> Bool { lhs.id == rhs.id }
  
  private static var undefinedNameIndex: Int = 0
  private static func newName() -> String {
    undefinedNameIndex += 1
    return "undefined_\(undefinedNameIndex)"
  }
}

/// Represent a patch node.
open class PatchNode: Identifiable, Equatable, ObservableObject {
  /// Nodes are uniquely identified using their index.
  public let id: Int
  /// Represent the patch name (e.g. the name of the fuction associated to it).
  public var name: String
  /// Input streams sockets.
  @Published public var inputs: [PatchSocket]
  /// Output stream sockets.
  @Published public var outputs: [PatchSocket]
  
  public init(
    id: PatchNode.ID,
    name: String,
    inputs: (SocketBuilder) -> Void,
    outputs: (SocketBuilder) -> Void
  ) {
    self.id = id
    self.name = name
    let inputsBuilder = SocketBuilder(nodeID: id, type: .input)
    let outputsBuilder = SocketBuilder(nodeID: id, type: .output)
    inputs(inputsBuilder)
    outputs(outputsBuilder)
    self.inputs = inputsBuilder.sockets
    self.outputs = outputsBuilder.sockets
  }
  
  public static func == (lhs: PatchNode, rhs: PatchNode) -> Bool { lhs.id == rhs.id }
}

extension Array where Element == PatchNode {
  
  /// All of the connections in this mesh.
  public var connections: [PatchSocketID: [PatchConnection]] {
    let outputs: [PatchSocket] = reduce(into: []) {
      $0 = $0 + $1.outputs
    }
    var connections: [PatchSocketID: [PatchConnection]] = [:]
    for output in outputs where !output.connections.isEmpty {
      connections[output.id] = output.connections
    }
    return connections
  }
}

/// Represent an connection between two sockets in the mesh.
public final class PatchConnection: Identifiable, Equatable {
  public let originID: PatchSocketID
  public let destinationID: PatchSocketID
  
  init(originID: PatchSocketID, destinationID: PatchSocketID) {
    self.originID = originID
    self.destinationID = destinationID
  }
  
  public var id: String { originID.id + "_" + destinationID.id }
  
  public static func == (lhs: PatchConnection, rhs: PatchConnection) -> Bool { lhs.id == rhs.id }
}

// MARK: - Builders.

public final class SocketBuilder {
  private let nodeID: Int
  private let type: PatchSocketID.StreamType
  var sockets: [PatchSocket] = []
  
  init(nodeID: Int, type: PatchSocketID.StreamType) {
    self.nodeID = nodeID
    self.type = type
  }
  
  @discardableResult
  public func add(index: Int, name: String? = nil) -> PatchSocket {
    let socket = PatchSocket(
      id: PatchSocketID(nodeID: nodeID, type: type, index: index),
      name: name)
    sockets.append(socket)
    return socket
  }
  
  @discardableResult
  public func add(tag: String, index: Int? = nil, name: String? = nil) -> PatchSocket {
    let socket = PatchSocket(
      id: PatchSocketID(nodeID: nodeID, type: type, tag: tag, index: index),
      name: name)
    sockets.append(socket)
    return socket
  }
}
