import SwiftData
import SwiftUI

@main
struct IndulgeApp: App {
  private let modelContainer: ModelContainer
  @State private var platform: HabitsPlatformSync

  init() {
    let usesPreviewStore =
      ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    _platform = State(initialValue: HabitsPlatformSync(enabled: !usesPreviewStore))
    do {
      let resolvedContainer: ModelContainer
      do {
        resolvedContainer = try IndulgeModelContainer.make(inMemory: usesPreviewStore)
      } catch {
        resolvedContainer = try IndulgeModelContainer.make(
          inMemory: usesPreviewStore,
          cloudSync: .localOnly
        )
      }
      modelContainer = resolvedContainer
    } catch {
      fatalError("Unable to create the local Indulge store: \(error)")
    }
  }

  var body: some Scene {
    WindowGroup {
      ContentView(platform: platform)
    }
    .modelContainer(modelContainer)
  }
}
