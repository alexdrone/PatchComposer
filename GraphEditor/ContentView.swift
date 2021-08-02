import SwiftUI

struct ContentView: View {
  
  @State var nodes: [PatchNode] = [testPatchIdx0(), testPatchIdx1()]
  
  var delegate: PatchEditorDelegate {
    PatchEditorDelegate {
      print($0.adjacencyList)
      self.nodes = $0
    }
  }
  
    var body: some View {
      VStack {
        PatchEditor(nodes: nodes, delegate: delegate)
        Button("Add Node") {
          nodes.append(testPatchIdxNew())
        }
        Spacer()
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// TEST

var idx: Int = 0

func testPatchIdx0() -> PatchNode {
  let node = PatchNode(
    id: 0,
    name: "ForegroundMask",
    inputs: {
      $0.add(index: 0)
      $0.add(tag: "MODEL")
    },
    outputs: {
      $0.add(index: 0)
      $0.add(tag: "MASK", name: "mask")
        .addConnection(nodeID: 1, tag: "MASK")
    })
  idx += 1
  return node
}

func testPatchIdx1() -> PatchNode {
  let node = PatchNode(
    id: 1,
    name: "Compose",
    inputs: {
      $0.add(index: 0)
      $0.add(tag: "OVERLAY")
      $0.add(tag: "MASK")
    },
    outputs: {
      $0.add(index: 0)
  })
  idx += 1
  return node
}

func testPatchIdx2() -> PatchNode {
  let node = PatchNode(
    id: idx,
    name: "ColorCorrection",
    inputs: {
      $0.add(index: 0)
      $0.add(tag: "TONE", index: 0)
      $0.add(tag: "TONE", index: 1)
    },
    outputs: {
      $0.add(index: 0)
    })
  idx += 1
  return node
}

func testPatchIdxNew() -> PatchNode {
  let node = PatchNode(
    id: idx,
    name: "Undefined",
    inputs: { _ in
    },
    outputs: { _ in
    })
  idx += 1
  return node
}
