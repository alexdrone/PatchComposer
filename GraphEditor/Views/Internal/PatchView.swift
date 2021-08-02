import SwiftUI

struct PatchView: View {
  let node: PatchNode
  
  @State private var position: CGPoint?
  @State private var showSettings: Bool = false
  
  @Environment(\.patchStyle) private var style: PatchStyle
  @EnvironmentObject private var store: PatchStore
  @EnvironmentObject private var geometry: PatchMeshGeometry

  private var highlighted: Bool { store.selectedNodeID == node.id }

  var body: some View {
    GeometryReader { geometryReader in
      Group {
        if let position = position {
          contentView
            .position(x: position.x, y: position.y)
            .gesture(dragGesture)
        } else {
          contentView
            .gesture(dragGesture)
        }
      }.onAppear {
        let size = CGSize(
          width: style.minimumSize.width + Constants.gutter,
          height:  style.minimumSize.height + Constants.gutter)
        let maxRows = Int(geometryReader.size.height / size.height)
        let col = CGFloat(node.id / maxRows)
        let row = CGFloat(node.id % maxRows)
        
        let initialPosition = CGPoint(
          x: col * size.width + (size.width / 2),
          y: row * size.height + (size.height / 2) + Constants.gutter)
        
        position = initialPosition
        geometry.meshContentSize = max(geometry.meshContentSize, initialPosition.x + size.width * 2)
      }
    }
  }
  
  @ViewBuilder
  private var contentView: some View {
    VStack(alignment: .leading, spacing: 0) {
      headerView.frame(alignment: .top)
      if showSettings {
        settingsView
      } else {
        mainView
      }
    }
    .frame(maxWidth:style.minimumSize.width)
    .padding(.bottom)
    .background(style.background)
    .cornerRadius(style.cornerRadius)
    .roundedBorder(radius: style.cornerRadius, hidden: !highlighted, color: style.selected)
    .patchShadow()
    .onTapGesture {
      store.selectedNodeID = node.id
    }
  }
  
  @ViewBuilder
  private var mainView: some View {
    Group {
      groupedInputViews
      groupedOutputsViews
    }
  }
  
  @ViewBuilder
  private var settingsView: some View {
    Group {
      PatchSettings(node: node)
    }
  }
  
  private var headerView: some View {
    HStack {
      Image(systemName: "f.cursive")
        .font(.body.bold())
        .foregroundColor(style.foreground)
        .padding([.leading])
      PatchText(node.name, bold: true).frame(height: Constants.headerHeight)
      Spacer()
      Group {
        Divider().frame(height: Constants.headerHeight)
        Button(action: toggleSettings) {
          Image(systemName: "slider.vertical.3")
            .font(.body.weight(.black))
            .foregroundColor(style.foreground)
            .help(Locale.settingsHelp)
        }
        Divider().frame(height: Constants.headerHeight)
        Button(action: delete) {
          Image(systemName: "xmark")
            .font(.body.weight(.black))
            .foregroundColor(style.foreground)
            .padding(.trailing)
            .help(Locale.deleteHelp)
        }
      }
      .onHover(perform: onHoverButton)
      .buttonStyle(.plain)
    }
    .frame(maxWidth: .infinity, idealHeight:  Constants.headerHeight)
    .background(style.header)
  }
  
  private var groupedInputViews: some View {
    VStack {
      ForEach(node.inputs) {
        PatchInputSocketView(node: node, id: $0.id)
      }
    }
    .padding(.top)
  }
  
  private var groupedOutputsViews: some View {
    VStack {
      ForEach(node.outputs) {
        PatchOutputSocketView(node: node, id: $0.id)
      }
    }
    .padding(.top)
  }
  
  /// The gesture that handles the item being dragged on the screen.
  private var dragGesture: some Gesture {
    DragGesture()
      .onChanged {
        guard !showSettings else { return }
        position = $0.location
      }
  }
  
  private func delete() {
    store.remove(node: node)
  }
  
  private func toggleSettings() {
    showSettings.toggle()
  }
  
  private func onHoverButton(hover: Bool) {
    if hover {
      NSCursor.pointingHand.push()
    } else {
      NSCursor.pop()
    }
  }
}

private enum Constants {
  static let gutter: CGFloat = 60
  static let headerHeight: CGFloat = 36
}
