import SwiftUI

struct PatchSettings: View {
  let node: PatchNode
  
  @State private var position: CGPoint?
  
  @Environment(\.patchStyle) private var style: PatchStyle
  @EnvironmentObject private var store: PatchStore
  @EnvironmentObject private var geometry: PatchMeshGeometry
  
  var body: some View {
    VStack {
      inputStreams
      outputStreams
      divider
      addNewStream
      divider
      renameButton
    }
    .frame(maxWidth: .infinity)
    .padding([.top, .leading, .trailing])
  }
  
  private var divider: some View {
    Divider().background(style.foreground).opacity(0.2)
  }
  
  @ViewBuilder
  private var inputStreams: some View {
    Group {
      PatchText(Locale.inputs, bold: true)
      if node.inputs.isEmpty {
        PatchText(Locale.noStreams, bold: false, highlighted: false)
          .padding()
      } else {
        ForEach(node.inputs) { input in
          PatchSettingsInputStream(socket: input, node: node)
        }
      }
    }
  }

  @ViewBuilder
  private var outputStreams: some View {
    Group {
      PatchText(Locale.outputs, bold: true)
      if node.outputs.isEmpty {
        PatchText(Locale.noStreams, bold: false, highlighted: false)
          .padding()
      } else {
        ForEach(node.outputs) { output in
          PatchSettingsOutputStream(socket: output, node: node)
        }
      }
    }
  }
  
  @ViewBuilder
  private var addNewStream: some View {
    HStack {
      Button(action: showAddStreamPrompt) {
        Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
          .font(.body.bold())
          .foregroundColor(style.foreground)
        PatchText(Locale.addStreamTitle, bold: true, highlighted: false)
      }
      .buttonStyle(.borderless)
      .onHover(perform: onHoverButton)
      Spacer()
    }
  }
    
    @ViewBuilder
    private var renameButton: some View {
      HStack {
        Button(action: showRenamePrompt) {
          Image(systemName: "f.cursive")
            .font(.body.bold())
            .foregroundColor(style.foreground)
          PatchText(Locale.renameNodeTitle, bold: true, highlighted: false)
        }
        .buttonStyle(.borderless)
        .onHover(perform: onHoverButton)
        Spacer()
      }
    }
  
  private func showAddStreamPrompt() {
    store.showAddStreamPrompt(node: node)
  }
  
  private func showRenamePrompt() {
    store.showRenamePrompt(node: node)
  }
}

private struct PatchSettingsOutputStream: View {
  let socket: PatchSocket
  let node: PatchNode
  
  @Environment(\.patchStyle) private var style: PatchStyle
  @EnvironmentObject private var store: PatchStore
  
  var body: some View {
    HStack {
      Spacer()
      PatchText(socket.id.label, bold: false, highlighted: false)
      Button(action: removeSocket) {
        removeSocketButtonLabel(style: style)
      }
      .buttonStyle(.borderless)
    }
  }
  
  private func removeSocket() {
    store.remove(socket: socket)
  }
}

private struct PatchSettingsInputStream: View {
  let socket: PatchSocket
  let node: PatchNode
  
  @Environment(\.patchStyle) private var style: PatchStyle
  @EnvironmentObject private var store: PatchStore
  
  var body: some View {
    HStack {
      Button(action: removeSocket) {
        removeSocketButtonLabel(style: style)
      }
      .buttonStyle(.borderless)
      PatchText(socket.id.label, bold: false, highlighted: false)
      Spacer()
    }
  }
  
  private func removeSocket() {
    store.remove(socket: socket)
  }
}

private func removeSocketButtonLabel(style: PatchStyle) -> some View {
  Image(systemName: "xmark")
    .font(.system(.caption).bold())
    .foregroundColor(style.foreground)
    .help(Locale.removeSocketHelp)
    .onHover(perform: onHoverButton)
}

private func onHoverButton(hover: Bool) {
  if hover {
    NSCursor.pointingHand.push()
  } else {
    NSCursor.pop()
  }
}

