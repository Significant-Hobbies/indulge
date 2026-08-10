import Foundation
import SwiftData
import Testing

@testable import Indulge

struct FocusJournalTests {
  @Test func interruptionTaxonomyIsBoundedAndStable() {
    #expect(FocusInterruptionSource.allCases == [.external, .drift, .environment])
    #expect(FocusInterruptionReason.allCases.count == 8)
    #expect(FocusReturnBlockage.allCases.count == 7)
    #expect(FocusInterruptionSource.allCases.allSatisfy { !$0.title.isEmpty && !$0.prompt.isEmpty })
    #expect(FocusInterruptionReason.allCases.allSatisfy { !$0.title.isEmpty })
    #expect(FocusReturnBlockage.allCases.allSatisfy { !$0.title.isEmpty })
  }

  @MainActor
  @Test func repositoryPersistsTheCompleteManualEventChain() throws {
    let container = try FocusModelContainer.make(inMemory: true)
    let repository = FocusRepository(context: container.mainContext)
    let start = Date(timeIntervalSince1970: 1_800_000_000)

    let session = try repository.startSession(intention: "Write the proposal", at: start)
    let interruption = try repository.beginInterruption(
      in: session, at: start.addingTimeInterval(600))

    #expect(try repository.activeSession()?.id == session.id)
    #expect(try repository.activeInterruption(for: session.id)?.id == interruption.id)

    try repository.classify(
      interruption,
      source: .drift,
      reason: .temptingApp,
      note: "Opened video after a difficult paragraph"
    )
    try repository.returnToFocus(
      from: interruption,
      blockage: .unclearNextStep,
      at: start.addingTimeInterval(900)
    )
    try repository.endSession(session, at: start.addingTimeInterval(1_800))

    let storedSession = try #require(repository.sessions().first)
    let storedInterruption = try #require(repository.interruptions().first)
    #expect(storedSession.endedAt == start.addingTimeInterval(1_800))
    #expect(storedInterruption.returnedAt == start.addingTimeInterval(900))
    #expect(storedInterruption.source == .drift)
    #expect(storedInterruption.reason == .temptingApp)
    #expect(storedInterruption.blockage == .unclearNextStep)
    #expect(storedInterruption.isComplete)
  }

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
      let container = try FocusModelContainer.make(storeURL: storeURL)
      let repository = FocusRepository(context: container.mainContext)
      sessionID = try repository.startSession(intention: "Restore me", at: start).id
    }

    do {
      let reopened = try FocusModelContainer.make(storeURL: storeURL)
      let repository = FocusRepository(context: reopened.mainContext)
      let restored = try repository.activeSession()
      let session = try #require(restored)
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
      let legacy = try FocusModelContainer.makeLegacyStore(at: storeURL)
      legacy.mainContext.insert(
        FocusSessionRecord(id: sessionID, intention: "Preserve me", startedAt: .distantPast)
      )
      try legacy.mainContext.save()
    }

    let migrated = try FocusModelContainer.make(storeURL: storeURL)
    let repository = FocusRepository(context: migrated.mainContext)
    #expect(migrated.schema.version == IndulgeDataSchemaV1.versionIdentifier)
    #expect(migrated.migrationPlan != nil)
    #expect(try repository.sessions().first?.id == sessionID)
  }

  @MainActor
  @Test func swiftDataProfileAndGeneratedMetadataPersistAndDeleteExplicitly() throws {
    let container = try FocusModelContainer.make(inMemory: true)
    let profileRepository = OnboardingProfileRepository(context: container.mainContext)
    let generatedRepository = GeneratedStateRepository(context: container.mainContext)
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

    try generatedRepository.deleteReflection(reflection)
    try generatedRepository.deleteCard(card)
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
      let container = try FocusModelContainer.make(storeURL: storeURL)
      try OnboardingProfileRepository(context: container.mainContext).save(profile)
    }

    do {
      let reopened = try FocusModelContainer.make(storeURL: storeURL)
      let restored = try OnboardingProfileRepository(context: reopened.mainContext).latest()
      #expect(restored == profile)
    }
  }

  @MainActor
  @Test func startupRepairDeterministicallyDeduplicatesImportedEvents() throws {
    let container = try FocusModelContainer.make(inMemory: true)
    let context = container.mainContext
    let repository = FocusRepository(context: context)
    let sessionID = UUID()
    let interruptionID = UUID()
    let start = Date(timeIntervalSince1970: 1_800_000_000)

    context.insert(FocusSessionRecord(id: sessionID, intention: "", startedAt: start))
    context.insert(
      FocusSessionRecord(
        id: sessionID,
        intention: "Retained intention",
        startedAt: start,
        endedAt: start.addingTimeInterval(1_800)
      )
    )
    context.insert(
      FocusInterruptionRecord(
        id: interruptionID,
        sessionID: sessionID,
        interruptedAt: start.addingTimeInterval(300)
      )
    )
    context.insert(
      FocusInterruptionRecord(
        id: interruptionID,
        sessionID: sessionID,
        interruptedAt: start.addingTimeInterval(300),
        returnedAt: start.addingTimeInterval(600),
        source: .drift,
        reason: .temptingApp,
        blockage: .temptingContent,
        note: "Complete import"
      )
    )
    try context.save()

    try repository.repairActiveRecords(at: start.addingTimeInterval(2_000))

    let sessions = try repository.sessions()
    let interruptions = try repository.interruptions()
    #expect(sessions.count == 1)
    #expect(sessions.first?.intention == "Retained intention")
    #expect(sessions.first?.endedAt == start.addingTimeInterval(1_800))
    #expect(interruptions.count == 1)
    #expect(interruptions.first?.isComplete == true)
    #expect(interruptions.first?.note == "Complete import")
  }

  @Test func dailySummarySplitsAtMidnightAndSubtractsRecovery() throws {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
    let firstDay = try #require(calendar.date(from: DateComponents(year: 2027, month: 1, day: 2)))
    let sessionStart = firstDay.addingTimeInterval(23.5 * 3_600)
    let sessionEnd = firstDay.addingTimeInterval(25 * 3_600)
    let interruptionStart = firstDay.addingTimeInterval(23.75 * 3_600)
    let interruptionEnd = firstDay.addingTimeInterval(24.25 * 3_600)
    let sessionID = UUID()

    let days = FocusSummary.days(
      sessions: [
        FocusSessionSnapshot(
          id: sessionID,
          intention: "Late work",
          startedAt: sessionStart,
          endedAt: sessionEnd
        )
      ],
      interruptions: [
        FocusInterruptionSnapshot(
          id: UUID(),
          sessionID: sessionID,
          interruptedAt: interruptionStart,
          returnedAt: interruptionEnd,
          source: .external,
          reason: .message,
          blockage: .urgentDemand
        )
      ],
      now: sessionEnd,
      calendar: calendar
    )

    #expect(days.count == 2)
    #expect(days[1].focusedDuration == 15 * 60)
    #expect(days[1].recoveryDuration == 15 * 60)
    #expect(days[1].interruptionCount == 1)
    #expect(days[0].focusedDuration == 45 * 60)
    #expect(days[0].recoveryDuration == 15 * 60)
    #expect(days[0].interruptionCount == 0)
  }

  @Test func aggregateWaitsForEvidenceAndUsesStableAuthoredTies() {
    let sessionID = UUID()
    let start = Date(timeIntervalSince1970: 1_800_000_000)
    let first = completedInterruption(
      sessionID: sessionID,
      start: start,
      source: .external,
      reason: .message,
      blockage: .urgentDemand,
      recovery: 60
    )
    let second = completedInterruption(
      sessionID: sessionID,
      start: start.addingTimeInterval(120),
      source: .drift,
      reason: .temptingApp,
      blockage: .temptingContent,
      recovery: 120
    )

    #expect(FocusSummary.aggregate(interruptions: [first, second]) == .learning(remaining: 1))

    let third = completedInterruption(
      sessionID: sessionID,
      start: start.addingTimeInterval(300),
      source: .environment,
      reason: .noise,
      blockage: .environment,
      recovery: 180
    )
    #expect(
      FocusSummary.aggregate(interruptions: [first, second, third])
        == .pattern(
          source: .external,
          reason: .message,
          blockage: .urgentDemand,
          averageRecovery: 120,
          observationCount: 3
        )
    )
  }

  private func completedInterruption(
    sessionID: UUID,
    start: Date,
    source: FocusInterruptionSource,
    reason: FocusInterruptionReason,
    blockage: FocusReturnBlockage,
    recovery: TimeInterval
  ) -> FocusInterruptionSnapshot {
    FocusInterruptionSnapshot(
      id: UUID(),
      sessionID: sessionID,
      interruptedAt: start,
      returnedAt: start.addingTimeInterval(recovery),
      source: source,
      reason: reason,
      blockage: blockage
    )
  }
}
