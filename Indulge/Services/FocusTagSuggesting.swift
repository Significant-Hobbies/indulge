import Foundation

struct FocusTagSuggestion: Equatable, Sendable {
  let source: FocusInterruptionSource
  let reason: FocusInterruptionReason
  let blockage: FocusReturnBlockage?
}

enum AppleCapabilityAvailability: Equatable, Sendable {
  case available
  case unavailable
}

struct AppleCapabilitySnapshot: Equatable, Sendable {
  let onDeviceIntelligence: AppleCapabilityAvailability
}

enum AppleIntelligenceOperationState<Value: Equatable & Sendable>: Equatable, Sendable {
  case idle
  case working
  case completed(Value)
  case cancelled
  case failed
}

enum ReflectionAngle: String, CaseIterable, Equatable, Sendable {
  case interruptionSource
  case returnBlockage
  case recoveryTime
}

enum ReflectionQuestion: String, CaseIterable, Equatable, Sendable {
  case protectStart
  case makeReturnEasier
  case noticeEarlier
}

struct GeneratedReflectionSelection: Equatable, Sendable {
  let angle: ReflectionAngle
  let question: ReflectionQuestion?
}

protocol AppleIntelligenceServing: Sendable {
  var capabilities: AppleCapabilitySnapshot { get }
  func suggestTags(for note: String) async throws -> FocusTagSuggestion?
  func selectReflection(for evidence: FocusEvidencePacket) async throws
    -> GeneratedReflectionSelection
}

struct ManualAppleIntelligenceService: AppleIntelligenceServing {
  let capabilities = AppleCapabilitySnapshot(onDeviceIntelligence: .unavailable)

  func suggestTags(for note: String) async throws -> FocusTagSuggestion? { nil }

  func selectReflection(for evidence: FocusEvidencePacket) async throws
    -> GeneratedReflectionSelection
  {
    evidence.authoredSelection
  }
}

#if canImport(FoundationModels)
  import FoundationModels

  @available(iOS 26.0, *)
  struct AppleFoundationModelsService: AppleIntelligenceServing {
    private let taggingModel = SystemLanguageModel(useCase: .contentTagging)
    private let reflectionModel = SystemLanguageModel.default

    var capabilities: AppleCapabilitySnapshot {
      AppleCapabilitySnapshot(
        onDeviceIntelligence:
          taggingModel.availability == .available && reflectionModel.availability == .available
          ? .available : .unavailable
      )
    }

    func suggestTags(for note: String) async throws -> FocusTagSuggestion? {
      let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty, capabilities.onDeviceIntelligence == .available else { return nil }
      try Task.checkCancellation()

      let session = LanguageModelSession(
        model: taggingModel,
        instructions: """
          Classify one private note about a focus interruption. Return only the generated fields. \
          Use the exact raw values described in the schema. Do not diagnose, judge, or add advice.
          """
      )
      let response = try await session.respond(
        to: "Interruption note: \(trimmed)",
        generating: GeneratedFocusTagSuggestion.self
      )
      try Task.checkCancellation()
      guard
        let source = FocusInterruptionSource(rawValue: response.content.source),
        let reason = FocusInterruptionReason(rawValue: response.content.reason)
      else { return nil }

      return FocusTagSuggestion(
        source: source,
        reason: reason,
        blockage: response.content.blockage.flatMap(FocusReturnBlockage.init(rawValue:))
      )
    }

    func selectReflection(for evidence: FocusEvidencePacket) async throws
      -> GeneratedReflectionSelection
    {
      guard capabilities.onDeviceIntelligence == .available else {
        return evidence.authoredSelection
      }
      try Task.checkCancellation()

      let session = LanguageModelSession(
        model: reflectionModel,
        instructions: """
          Choose which supplied aggregate deserves gentle attention. Return only exact schema keys. \
          Do not create prose, facts, causes, diagnoses, advice, events, or durations.
          """
      )
      let response = try await session.respond(
        to: evidence.modelPrompt,
        generating: GeneratedReflectionChoice.self
      )
      try Task.checkCancellation()

      guard let angle = ReflectionAngle(rawValue: response.content.angle) else {
        return evidence.authoredSelection
      }
      let question = response.content.question.flatMap(ReflectionQuestion.init(rawValue:))
      return GeneratedReflectionSelection(angle: angle, question: question)
    }
  }

  @available(iOS 26.0, *)
  @Generable
  private struct GeneratedFocusTagSuggestion {
    @Guide(
      description:
        "One of: external, drift, environment. Choose external for another person, call, or message; drift for self-initiated switching or thoughts; environment for noise or body needs."
    )
    let source: String

    @Guide(
      description:
        "One of: personOrCall, message, difficultTask, randomThought, temptingApp, noise, bodyNeed, other."
    )
    let reason: String

    @Guide(
      description:
        "If the note clearly explains difficulty returning, one of: urgentDemand, temptingContent, unclearNextStep, emotion, fatigue, environment, notSure. Otherwise omit it."
    )
    let blockage: String?
  }

  @available(iOS 26.0, *)
  @Generable
  private struct GeneratedReflectionChoice {
    @Guide(description: "One of: interruptionSource, returnBlockage, recoveryTime.")
    let angle: String

    @Guide(description: "One of: protectStart, makeReturnEasier, noticeEarlier; or omit it.")
    let question: String?
  }
#endif

enum AppleIntelligenceServiceFactory {
  static func make() -> any AppleIntelligenceServing {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, *) {
        let apple = AppleFoundationModelsService()
        if apple.capabilities.onDeviceIntelligence == .available { return apple }
      }
    #endif
    return ManualAppleIntelligenceService()
  }
}
