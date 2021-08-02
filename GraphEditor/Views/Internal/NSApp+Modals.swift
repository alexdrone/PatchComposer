import AppKit

func NSAppBundle() -> Bundle { Bundle(identifier: "com.apple.AppKit")! }

func NSAppModalTextField(
  title: String,
  prompt: String,
  handler: @escaping (String?) -> Void
) {
  guard let window = NSApp.keyWindow else {
    handler(nil)
    return
  }
  let alert = NSAlert()
  alert.addButton(withTitle: NSAppBundle().localizedString(
    forKey: "Ok",
    value: nil,
    table: nil))
  alert.addButton(withTitle: NSAppBundle().localizedString(
    forKey: "Cancel",
    value: nil,
    table: nil))
  alert.messageText = title
  alert.informativeText = prompt
  let width = Constants.accessoryViewWidth
  let height = Constants.accessoryViewHeight
  let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: width, height: height))
  alert.accessoryView = textField
  alert.beginSheetModal(for: window) { response in
    guard response == .alertFirstButtonReturn else {
      handler(nil)
      return
    }
    handler(textField.stringValue)
  }
}

func NSAppModalTextFieldAndComboBox(
  title: String,
  prompt: String,
  defaultValue: String,
  values: [String],
  handler: @escaping (String?, String) -> Void
) {
  guard let window = NSApp.keyWindow else {
    handler(nil, "")
    return
  }
  let alert = NSAlert()
  alert.addButton(withTitle: NSAppBundle().localizedString(
    forKey: "Ok",
    value: nil,
    table: nil))
  alert.addButton(withTitle: NSAppBundle().localizedString(
    forKey: "Cancel",
    value: nil,
    table: nil))
  alert.messageText = title
  alert.informativeText = prompt
  let width = Constants.accessoryViewWidth
  let height = Constants.accessoryViewHeight
  let popup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: width, height: height))
  popup.addItems(withTitles: values)
  let textField = NSTextField(frame: NSRect(x: 0, y: height * 1.5, width: width, height: height))
  let accessoryView = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height * 2.5))
  accessoryView.addSubview(popup)
  accessoryView.addSubview(textField)
  alert.accessoryView = accessoryView
  alert.beginSheetModal(for: window) { response in
    guard response == .alertFirstButtonReturn else {
      handler(nil, "")
      return
    }
    handler(popup.selectedItem?.title ?? defaultValue, textField.stringValue)
  }
}

func NSAppModalAlert(title: String, prompt: String) {
  guard let window = NSApp.keyWindow else { return }
  let alert = NSAlert()
  alert.addButton(withTitle: NSAppBundle().localizedString(
    forKey: "Ok",
    value: nil,
    table: nil))
  alert.addButton(withTitle: NSAppBundle().localizedString(
    forKey: "Cancel",
    value: nil,
    table: nil))
  alert.messageText = title
  alert.informativeText = prompt
  alert.beginSheetModal(for: window) { _ in }
}

private enum Constants {
  static let accessoryViewWidth: CGFloat = 200
  static let accessoryViewHeight: CGFloat = 24
}
