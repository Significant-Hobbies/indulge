import SwiftData
import SwiftUI

@main
struct IndulgeApp: App {
  private let modelContainer: ModelContainer

  init() {
    let arguments = ProcessInfo.processInfo.arguments
    let usesPreviewStore =
      arguments.contains { $0.hasPrefix("--app-focus") }
      || ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    do {
      modelContainer = try FocusModelContainer.make(inMemory: usesPreviewStore)
    } catch {
      fatalError("Unable to create the local focus store: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(modelContainer)
  }
}
