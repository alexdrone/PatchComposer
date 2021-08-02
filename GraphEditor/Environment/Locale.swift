import Foundation

enum Locale {
  // TODO: Adds l10n support.
  static var undefined: String { "undefined" }
  static var undefinedHelp: String { "The stream has not been named yet." }
  static var renameTitle: String { "Rename Stream" }
  static var renamePrompt: String { "Add a custom identifier for the selected stream." }
  static var renameFailed: String { "The stream name is already in use."}
  static var renameNodeTitle: String { "Set calculator name" }
  static var renameNodePrompt: String { "Set the calculator name for this node." }
  static var addStreamTitle: String { "Add new stream" }
  static var addStreamPrompt: String { "Add a new input/output stream for this node." }
  static var delete: String { "Delete" }
  static var rename: String { "Rename" }
  static var renameHelp: String { "Click to rename the stream." }
  static var inputs: String { "Input Streams" }
  static var outputs: String { "Output Streams" }
  static var noStreams: String { "No streams defined." }
  static var removeSocketHelp: String { "Remove the stream from this node." }
  static var settingsHelp: String { "Configure this node" }
  static var deleteHelp: String { "Remove this node" }
}
