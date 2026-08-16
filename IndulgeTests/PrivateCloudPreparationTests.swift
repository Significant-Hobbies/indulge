import Foundation
import SwiftData
import Testing

@testable import Indulge

@MainActor
struct PrivateCloudPreparationTests {
  @Test func simulatorAndMemoryStoresStayExplicitlyLocal() throws {
    #if targetEnvironment(simulator)
      #expect(IndulgeModelContainer.CloudSyncSelection.applicationDefault == .localOnly)
    #endif

    let container = try IndulgeModelContainer.make(
      inMemory: true,
      cloudSync: .privateDatabase(
        containerIdentifier: IndulgeModelContainer.privateCloudKitContainerIdentifier)
    )
    let session = FocusSessionRecord(intention: "Local test")
    container.mainContext.insert(session)
    try container.mainContext.save()
    #expect(session.intention == "Local test")
  }

  @Test func allDataDeletionClearsEverySyncedModelFamily() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("indulge-delete-all-\(UUID().uuidString)", isDirectory: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let container = try IndulgeModelContainer.make(inMemory: true)
    let context = container.mainContext
    let session = FocusSessionRecord(intention: "Delete me")
    context.insert(session)
    context.insert(FocusInterruptionRecord(sessionID: session.id))
    context.insert(try OnboardingProfileRecord(profile: .appPreview))
    context.insert(
      GeneratedReflectionRecord(
        evidenceRevision: "revision",
        headline: "Headline",
        observation: "Observation"
      ))
    context.insert(
      try FutureLifeCardRecord(
        imageFileName: "already-absent.png",
        lifeDirections: [.calm]
      ))
    context.insert(
      TradeRecord(
        indulgence: .television,
        reclaimTarget: .fifteen,
        destination: .calm
      ))
    try context.save()

    try AllIndulgeDataRepository(
      context: context,
      cardAssets: FutureLifeCardAssetStore(rootURL: directory)
    ).deleteAll()

    #expect(try context.fetch(FetchDescriptor<FocusSessionRecord>()).isEmpty)
    #expect(try context.fetch(FetchDescriptor<FocusInterruptionRecord>()).isEmpty)
    #expect(try context.fetch(FetchDescriptor<OnboardingProfileRecord>()).isEmpty)
    #expect(try context.fetch(FetchDescriptor<GeneratedReflectionRecord>()).isEmpty)
    #expect(try context.fetch(FetchDescriptor<FutureLifeCardRecord>()).isEmpty)
    #expect(try context.fetch(FetchDescriptor<TradeRecord>()).isEmpty)
  }
}
