import SwiftUI

public struct PatchEditor: View {
  /// The nodes that will be displayed in the mesh.
  public let nodes: [PatchNode]

  /// Callbacks executed whenever the editor has performed a change on the mesh.
  public let delegate: PatchEditorDelegate?
  
  @State private var panOFfset: CGSize = .zero
  
  @Environment(\.patchStyle) public var style: PatchStyle
  @StateObject private var geometry: PatchMeshGeometry = .init()
  @StateObject private var store: PatchStore = .init()
  
  static let coordinateSpace: String = #file
  
  public var body: some View {
    ScrollView(.horizontal) {
      ZStack {
        PatchMesh()
        ForEach(store.nodes) { node in
          PatchView(node: node)
        }
      }
      .frame(
        minWidth: geometry.meshContentSize,
        maxWidth: .infinity,
        maxHeight: .infinity)
      .background(style.grid)
      .coordinateSpace(name: PatchEditor.coordinateSpace)
      .offset(panOFfset)
      .environmentObject(store)
      .environmentObject(geometry)
      .onAppear { updateStore() }
      .onChange(of: nodes) { updateStore(nodes: $0) }
    }
  }
  
  private func updateStore(nodes newNodes: [PatchNode]? = nil) {
    store.delegate = delegate
    store.nodes = newNodes ?? nodes
  }
}
