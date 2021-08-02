import SwiftUI

public struct PatchEditorDelegate {
  /// Callback called whenever anything has changed in the nodes collection.
  /// Use the other delegate methods to have fine grain control over what has changed.
  public let didChangePatchNodes: ([PatchNode]) -> Void
  
  /// Whether a connection from the first to the second socket is possible.
  public let shouldAddConnection: (PatchConnection) -> Bool
  
  public init(
    shouldAddConnection: @escaping (PatchConnection) -> Bool = { _ in true },
    didChangePatchNodes: @escaping ([PatchNode]) -> Void = { _ in }
  ) {
    self.shouldAddConnection = shouldAddConnection
    self.didChangePatchNodes = didChangePatchNodes
  }
}
