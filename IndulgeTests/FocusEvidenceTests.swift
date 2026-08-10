import Foundation
import SwiftData
import Testing

@testable import Indulge

@MainActor
struct FocusEvidenceTests {
  @Test func insufficientEvidenceDoesNotCreatePacket() {
    let profile = profile()
    let events = [completedEvent(index: 0), completedEvent(index: 1)]

    #expect(FocusEvidenceBuilder.make(profile: profile, interruptions: events) == nil)
  }

  @Test func revisionIsStableAndChangesWithAuthoritativeEvidence() {
    let profile = profile()
    let events = (0..<3).map { completedEvent(index: $0) }
    let first = FocusEvidenceBuilder.make(profile: profile, interruptions: events)
    let second = FocusEvidenceBuilder.make(
      profile: profile, interruptions: Array(events.reversed()))
    let changed = FocusEvidenceBuilder.make(
      profile: profile,
      interruptions: events + [completedEvent(index: 3, source: .external)]
    )

    #expect(first?.evidenceRevision == second?.evidenceRevision)
    #expect(first?.evidenceRevision != changed?.evidenceRevision)
  }

  @Test func promptContainsOnlyBoundedAggregates() throws {
    var privateProfile = profile()
    privateProfile.preferredName = "Private Name"
    let packet = try #require(
      FocusEvidenceBuilder.make(
        profile: privateProfile,
        interruptions: (0..<3).map { completedEvent(index: $0) }
      ))

    #expect(packet.modelPrompt.contains("Completed observations: 3"))
    #expect(packet.modelPrompt.contains("Average recovery seconds: 120"))
    #expect(!packet.modelPrompt.contains("Private Name"))
    #expect(!packet.modelPrompt.localizedCaseInsensitiveContains("note"))
  }

  @Test func reflectionUsesOnlyPacketFactsAndBoundedSchema() throws {
    let packet = try #require(
      FocusEvidenceBuilder.make(
        profile: profile(), interruptions: (0..<3).map { completedEvent(index: $0) }))
    let reflection = packet.reflection(
      for: GeneratedReflectionSelection(angle: .recoveryTime, question: .makeReturnEasier))

    #expect(reflection.evidenceRevision == packet.evidenceRevision)
    #expect(
      reflection.observation
        == "Across 3 completed observations, returning took about 2 minutes on average.")
    #expect(reflection.question == "What could make returning feel one step easier next time?")
  }

  @Test func manualFallbackReturnsAuthoredSelection() async throws {
    let packet = try #require(
      FocusEvidenceBuilder.make(
        profile: profile(), interruptions: (0..<3).map { completedEvent(index: $0) }))

    let selection = try await ManualAppleIntelligenceService().selectReflection(for: packet)

    #expect(selection == packet.authoredSelection)
  }

  @Test func resolverCachesByRevisionAndInvalidatesOldEvidence() async throws {
    let container = try FocusModelContainer.make(inMemory: true)
    let repository = GeneratedStateRepository(context: container.mainContext)
    let packet = try #require(
      FocusEvidenceBuilder.make(
        profile: profile(), interruptions: (0..<3).map { completedEvent(index: $0) }))
    let service = StubIntelligenceService(
      result: .success(GeneratedReflectionSelection(angle: .returnBlockage, question: nil)))
    let resolver = GroundedReflectionResolver(service: service)

    let first = await resolver.resolve(evidence: packet, repository: repository)
    let second = await resolver.resolve(evidence: packet, repository: repository)

    guard case .completed(let firstReflection) = first,
      case .completed(let secondReflection) = second
    else {
      Issue.record("Expected completed reflections")
      return
    }
    #expect(firstReflection == secondReflection)
    #expect(await service.callCount == 1)

    let changedPacket = try #require(
      FocusEvidenceBuilder.make(
        profile: profile(),
        interruptions: (0..<4).map { completedEvent(index: $0) }
      ))
    _ = await resolver.resolve(evidence: changedPacket, repository: repository)
    let records = try container.mainContext.fetch(FetchDescriptor<GeneratedReflectionRecord>())
    #expect(records.count == 1)
    #expect(records.first?.evidenceRevision == changedPacket.evidenceRevision)
  }

  @Test func cancellationAndFailureExposeStatesWithoutCachingOutput() async throws {
    let container = try FocusModelContainer.make(inMemory: true)
    let repository = GeneratedStateRepository(context: container.mainContext)
    let packet = try #require(
      FocusEvidenceBuilder.make(
        profile: profile(), interruptions: (0..<3).map { completedEvent(index: $0) }))

    let cancelled = await GroundedReflectionResolver(
      service: StubIntelligenceService(result: .failure(CancellationError()))
    ).resolve(evidence: packet, repository: repository)
    let failed = await GroundedReflectionResolver(
      service: StubIntelligenceService(result: .failure(StubFailure.failed))
    ).resolve(evidence: packet, repository: repository)

    #expect(cancelled == .cancelled)
    #expect(failed == .failed)
    #expect(try container.mainContext.fetch(FetchDescriptor<GeneratedReflectionRecord>()).isEmpty)
    #expect(
      packet.reflection(for: packet.authoredSelection).observation.contains(
        "3 completed observations"))
  }

  private func profile() -> OnboardingProfile {
    var profile = OnboardingProfile()
    profile.primaryIndulgence = .shortVideo
    profile.lifeDirections = [.focus, .sleep]
    return profile
  }

  private func completedEvent(
    index: Int,
    source: FocusInterruptionSource = .drift
  ) -> FocusInterruptionSnapshot {
    let start = Date(timeIntervalSince1970: Double(index * 1_000))
    return FocusInterruptionSnapshot(
      id: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index + 1))!,
      sessionID: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
      interruptedAt: start,
      returnedAt: start.addingTimeInterval(120),
      source: source,
      reason: .temptingApp,
      blockage: .temptingContent
    )
  }
}

private enum StubFailure: Error, Sendable {
  case failed
}

private actor StubIntelligenceService: AppleIntelligenceServing {
  nonisolated let capabilities = AppleCapabilitySnapshot(onDeviceIntelligence: .available)
  private(set) var callCount = 0
  private let result: Result<GeneratedReflectionSelection, any Error & Sendable>

  init(result: Result<GeneratedReflectionSelection, any Error & Sendable>) {
    self.result = result
  }

  func suggestTags(for note: String) async throws -> FocusTagSuggestion? { nil }

  func selectReflection(for evidence: FocusEvidencePacket) async throws
    -> GeneratedReflectionSelection
  {
    callCount += 1
    return try result.get()
  }
}
