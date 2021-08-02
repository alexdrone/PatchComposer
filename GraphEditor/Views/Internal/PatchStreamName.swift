import SwiftUI

struct PatchStreamName: View {
  let socket: PatchSocket
  
  @Environment(\.patchStyle) var style: PatchStyle
  @EnvironmentObject private var store: PatchStore
  
  private var isConnectionSelected: Bool {
    store.selectedConnection?.originID == socket.id
  }
  
  private var truncatedName: String {
    var name = socket.name ?? Locale.undefined
    let max = 35
    if name.lengthOfBytes(using: .utf8) > max {
      let index = name.index(name.startIndex, offsetBy: max)
      name = name.lengthOfBytes(using: .utf8) > max ? name.substring(to: index) + "…" : name
    }
    return ":" + name
  }
  
  var body: some View {
    if socket.id.type != .output || socket.connections.isEmpty {
      EmptyView()
    } else {
      HStack(spacing: 0) {
        Text(truncatedName)
          .patchTextStyle(style: style, bold: true, highlighted: isConnectionSelected)
          .onTapGesture { store.showRenamePrompt(originID: socket.id) }
          .help(Locale.renameHelp)
          .onHover(perform: onHover)
        if socket.name == nil {
          Image(systemName: "exclamationmark.circle.fill")
            .font(.system(.caption).bold())
            .foregroundColor(style.selected)
            .help(Locale.undefinedHelp)
        }
      }
    }
  }
  
  private func onHover(hover: Bool) {
    if hover {
      NSCursor.pointingHand.push()
    } else {
      NSCursor.pop()
    }
  }
}
