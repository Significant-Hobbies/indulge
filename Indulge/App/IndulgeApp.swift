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
      let resolvedContainer: ModelContainer
      do {
        resolvedContainer = try FocusModelContainer.make(inMemory: usesPreviewStore)
      } catch {
        resolvedContainer = try FocusModelContainer.make(
          inMemory: usesPreviewStore,
          cloudSync: .localOnly
        )
      }
      modelContainer = resolvedContainer
      try FocusRepository(context: resolvedContainer.mainContext).repairActiveRecords()
    } catch {
      fatalError("Unable to create the local Indulge store: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(modelContainer)
  }
}
