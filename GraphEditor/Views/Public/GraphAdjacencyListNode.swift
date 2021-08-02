import Foundation

/// A compact representation of the node with its input/output streams.
public struct GraphAdjacencyListNode: Identifiable, Equatable, Hashable, CustomStringConvertible {
  public let name: String
  public let index: Int
  public let inputs: [String]
  public let outputs: [String]
  
  public var id: Int { index }
  
  public var description: String {
    "\n[\(index)]: { name: \(name), inputs: \(inputs), outputs: \(outputs)}"
  }
}

extension Array where Element == PatchNode {
  /// Returns a compact graph represetation for the current states in the patch editor.
  public var adjacencyList: [GraphAdjacencyListNode] {
    let connections = connections
    
    func streamTag(_ socketID: PatchSocketID) -> String {
      if socketID.tag != nil {
        return socketID.label + ":"
      }
      return ""
    }
    
    var result: [GraphAdjacencyListNode] = []
    for node in self {
      let inputConnections = connections.values
        .flatMap { $0 }
        .filter { $0.destinationID.nodeID == node.id }
      let outputConnections = connections.values
        .flatMap { $0 }
        .filter { $0.originID.nodeID == node.id }
      
      var inputs: [String] = []
      for connection in inputConnections {
        guard
          let originNode = first(where: { $0.id == connection.originID.nodeID }),
          let originSocket = originNode.outputs.first(where: { $0.id == connection.originID })
        else {
          continue
        }
        let input = streamTag(connection.destinationID) + originSocket.name
        inputs.append(input)
      }
      var outputs: [String] = []
      for connection in outputConnections {
        guard
          let originNode = first(where: { $0.id == connection.originID.nodeID }),
          let originSocket = originNode.outputs.first(where: { $0.id == connection.originID })
        else {
          continue
        }
        let output = streamTag(connection.originID) + originSocket.name
        outputs.append(output)
      }
      result.append(GraphAdjacencyListNode(
        name: node.name,
        index: node.id,
        inputs: inputs.uniqued(),
        outputs: outputs.uniqued()))
    }
    return result
  }
}

extension Array where Element: Hashable {
  
  /// Removes all of the duplicated elements from this array.
  func uniqued() -> [Element] {
    var seen = Set<Element>()
    return filter{ seen.insert($0).inserted }
  }
}
