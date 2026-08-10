import Foundation
import SwiftData
import Testing

@testable import Indulge

@MainActor
struct PrivateCloudPreparationTests {
  @Test func simulatorAndMemoryStoresStayExplicitlyLocal() throws {
    #if targetEnvironment(simulator)
      #expect(FocusModelContainer.CloudSyncSelection.applicationDefault == .localOnly)
    #endif

    let container = try FocusModelContainer.make(
      inMemory: true,
      cloudSync: .privateDatabase(
        containerIdentifier: FocusModelContainer.privateCloudKitContainerIdentifier)
    )
    let session = try FocusRepository(context: container.mainContext).startSession(
      intention: "Local test"
    )
    #expect(session.intention == "Local test")
  }

  @Test func competingActiveChainsConvergeDeterministically() throws {
    let container = try FocusModelContainer.make(inMemory: true)
    let context = container.mainContext
    let repository = FocusRepository(context: context)
    let olderStart = Date(timeIntervalSince1970: 1_000)
    let newerStart = Date(timeIntervalSince1970: 2_000)
    let older = FocusSessionRecord(startedAt: olderStart)
    let newer = FocusSessionRecord(startedAt: newerStart)
    context.insert(older)
    context.insert(newer)
    context.insert(FocusInterruptionRecord(sessionID: newer.id, interruptedAt: newerStart))
    context.insert(
      FocusInterruptionRecord(
        sessionID: newer.id,
        interruptedAt: newerStart.addingTimeInterval(100)
      ))
    try context.save()

    try repository.repairActiveRecords(at: newerStart.addingTimeInterval(500))

    #expect(try repository.activeSession()?.id == newer.id)
    #expect(older.endedAt == newerStart)
    let openInterruptions = try repository.interruptions().filter { $0.returnedAt == nil }
    #expect(openInterruptions.count == 1)
    #expect(openInterruptions.first?.interruptedAt == newerStart.addingTimeInterval(100))
  }

  @Test func allDataDeletionClearsEverySyncedModelFamily() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent("indulge-delete-all-\(UUID().uuidString)", isDirectory: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let container = try FocusModelContainer.make(inMemory: true)
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
  }
}
