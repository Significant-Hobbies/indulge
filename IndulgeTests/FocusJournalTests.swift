import Foundation
import SwiftData
import Testing

@testable import Indulge

struct FocusJournalTests {
  @MainActor
  @Test func localStoreRestoresAnOpenSessionAfterContainerRecreation() throws {
    let directory = FileManager.default.temporaryDirectory.appending(
      path: "indulge-focus-\(UUID().uuidString)",
      directoryHint: .isDirectory
    )
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let storeURL = directory.appending(path: "focus.store")
    let start = Date(timeIntervalSince1970: 1_800_000_000)
    let sessionID: UUID

    do {
      let container = try IndulgeModelContainer.make(storeURL: storeURL)
      let session = FocusSessionRecord(intention: "Restore me", startedAt: start)
      sessionID = session.id
      container.mainContext.insert(session)
      try container.mainContext.save()
    }

    do {
      let reopened = try IndulgeModelContainer.make(storeURL: storeURL)
      let session = try #require(
        reopened.mainContext.fetch(FetchDescriptor<FocusSessionRecord>()).first)
      #expect(session.id == sessionID)
      #expect(session.intention == "Restore me")
      #expect(session.startedAt == start)
    }
  }

  @MainActor
  @Test func legacyLocalStoreOpensThroughTheVersionedMigrationPlan() throws {
    let directory = FileManager.default.temporaryDirectory.appending(
      path: "indulge-migration-\(UUID().uuidString)",
      directoryHint: .isDirectory
    )
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let storeURL = directory.appending(path: "indulge.store")
    let sessionID = UUID()

    do {
      let legacy = try IndulgeModelContainer.makeLegacyStore(at: storeURL)
      legacy.mainContext.insert(
        FocusSessionRecord(id: sessionID, intention: "Preserve me", startedAt: .distantPast)
      )
      try legacy.mainContext.save()
    }

    let migrated = try IndulgeModelContainer.make(storeURL: storeURL)
    #expect(migrated.schema.version == IndulgeDataSchemaV2.versionIdentifier)
    #expect(migrated.migrationPlan != nil)
    #expect(
      try migrated.mainContext.fetch(FetchDescriptor<FocusSessionRecord>()).first?.id == sessionID)
    #expect(IndulgeAppTab.allCases == [.life, .trade, .history])
    #expect(
      IndulgeLaunchRoute.resolve(arguments: ["Indulge", "--app-focus"])
        == .application(tab: .life, activeTrade: false)
    )
  }

  @MainActor
  @Test func versionOneProfileStoreMigratesToVersionTwoWithTradeSupport() throws {
    let directory = FileManager.default.temporaryDirectory.appending(
      path: "indulge-v1-v2-\(UUID().uuidString)",
      directoryHint: .isDirectory
    )
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let storeURL = directory.appending(path: "indulge.store")
    let profile = OnboardingProfile(
      preferredName: "Maya",
      activities: [.television],
      primaryIndulgence: .television,
      lifeDirections: [.presence]
    )

    do {
      let versionOne = try IndulgeModelContainer.makeV1Store(at: storeURL)
      try OnboardingProfileRepository(context: versionOne.mainContext).save(profile)
    }

    let versionTwo = try IndulgeModelContainer.make(storeURL: storeURL)
    #expect(versionTwo.schema.version == IndulgeDataSchemaV2.versionIdentifier)
    #expect(try OnboardingProfileRepository(context: versionTwo.mainContext).latest() == profile)
    #expect(try versionTwo.mainContext.fetch(FetchDescriptor<TradeRecord>()).isEmpty)
  }

  @MainActor
  @Test func swiftDataProfileAndLegacyMetadataPersistAndDeleteExplicitly() throws {
    let container = try IndulgeModelContainer.make(inMemory: true)
    let profileRepository = OnboardingProfileRepository(context: container.mainContext)
    let profile = OnboardingProfile(
      preferredName: "Maya",
      activities: [.television],
      primaryIndulgence: .television,
      lifeDirections: [.presence]
    )
    try profileRepository.save(profile)

    let reflection = GeneratedReflectionRecord(
      evidenceRevision: "evidence-v1",
      headline: "A pattern is taking shape",
      observation: "One interruption was recorded."
    )
    let card = try FutureLifeCardRecord(
      imageFileName: "future-life-card.jpg",
      lifeDirections: [.presence]
    )
    container.mainContext.insert(reflection)
    container.mainContext.insert(card)
    try container.mainContext.save()

    #expect(try profileRepository.latest() == profile)
    #expect(
      try container.mainContext.fetch(FetchDescriptor<GeneratedReflectionRecord>()).count == 1)
    #expect(try container.mainContext.fetch(FetchDescriptor<FutureLifeCardRecord>()).count == 1)

    container.mainContext.delete(reflection)
    container.mainContext.delete(card)
    try container.mainContext.save()
    try profileRepository.delete()

    #expect(try profileRepository.latest() == nil)
    #expect(try container.mainContext.fetch(FetchDescriptor<GeneratedReflectionRecord>()).isEmpty)
    #expect(try container.mainContext.fetch(FetchDescriptor<FutureLifeCardRecord>()).isEmpty)
  }

  @MainActor
  @Test func swiftDataProfileRestoresAfterContainerRecreation() throws {
    let directory = FileManager.default.temporaryDirectory.appending(
      path: "indulge-profile-store-\(UUID().uuidString)",
      directoryHint: .isDirectory
    )
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let storeURL = directory.appending(path: "indulge.store")
    let profile = OnboardingProfile(
      preferredName: "Maya",
      activities: [.television],
      primaryIndulgence: .television,
      lifeDirections: [.creativity]
    )

    do {
      let container = try IndulgeModelContainer.make(storeURL: storeURL)
      try OnboardingProfileRepository(context: container.mainContext).save(profile)
    }

    do {
      let reopened = try IndulgeModelContainer.make(storeURL: storeURL)
      let restored = try OnboardingProfileRepository(context: reopened.mainContext).latest()
      #expect(restored == profile)
    }
  }

}
