import Foundation

struct FocusEvidencePacket: Equatable, Sendable {
  let evidenceRevision: String
  let primaryIndulgence: IndulgenceChoice?
  let lifeDirections: [LifeDirection]
  let observationCount: Int
  let dominantSource: FocusInterruptionSource
  let dominantReason: FocusInterruptionReason
  let dominantBlockage: FocusReturnBlockage
  let averageRecoverySeconds: Int

  var authoredSelection: GeneratedReflectionSelection {
    GeneratedReflectionSelection(angle: .interruptionSource, question: .noticeEarlier)
  }

  var modelPrompt: String {
    """
    Evidence revision: \(evidenceRevision)
    Completed observations: \(observationCount)
    Most frequent interruption source: \(dominantSource.rawValue)
    Most frequent interruption reason: \(dominantReason.rawValue)
    Most frequent return blockage: \(dominantBlockage.rawValue)
    Average recovery seconds: \(averageRecoverySeconds)
    Allowed angles: \(ReflectionAngle.allCases.map(\.rawValue).joined(separator: ", "))
    Allowed questions: \(ReflectionQuestion.allCases.map(\.rawValue).joined(separator: ", "))
    """
  }

  func reflection(for selection: GeneratedReflectionSelection) -> PersonalReflection {
    let headline: String
    let observation: String
    switch selection.angle {
    case .interruptionSource:
      headline = "A pattern is becoming visible"
      observation =
        "Across \(observationCount) completed observations, \(dominantSource.title.lowercased()) interruptions appeared most often."
    case .returnBlockage:
      headline = "Returning has a recurring shape"
      observation =
        "Across \(observationCount) completed observations, \(dominantBlockage.shortTitle.lowercased()) was the most common barrier to returning."
    case .recoveryTime:
      headline = "Your return time is taking shape"
      observation =
        "Across \(observationCount) completed observations, returning took about \(Self.durationText(averageRecoverySeconds)) on average."
    }

    return PersonalReflection(
      evidenceRevision: evidenceRevision,
      headline: headline,
      observation: observation,
      question: selection.question.map(Self.questionText)
    )
  }

  private static func durationText(_ seconds: Int) -> String {
    let minutes = max(1, Int((Double(seconds) / 60).rounded()))
    return minutes == 1 ? "1 minute" : "\(minutes) minutes"
  }

  private static func questionText(_ question: ReflectionQuestion) -> String {
    switch question {
    case .protectStart: "What might help protect the beginning of your next focus session?"
    case .makeReturnEasier: "What could make returning feel one step easier next time?"
    case .noticeEarlier: "What might help you notice this pattern a little earlier?"
    }
  }
}

struct PersonalReflection: Equatable, Sendable {
  let evidenceRevision: String
  let headline: String
  let observation: String
  let question: String?
}

enum FocusEvidenceBuilder {
  static func make(
    profile: OnboardingProfile,
    interruptions: [FocusInterruptionSnapshot]
  ) -> FocusEvidencePacket? {
    guard
      case .pattern(let source, let reason, let blockage, let averageRecovery, let count) =
        FocusSummary.aggregate(interruptions: interruptions)
    else { return nil }

    let directions = profile.lifeDirections.sorted { $0.rawValue < $1.rawValue }
    let averageSeconds = max(0, Int(averageRecovery.rounded()))
    let canonical = [
      "indulgence=\(profile.primaryIndulgence?.rawValue ?? "none")",
      "directions=\(directions.map(\.rawValue).joined(separator: ","))",
      "count=\(count)",
      "source=\(source.rawValue)",
      "reason=\(reason.rawValue)",
      "blockage=\(blockage.rawValue)",
      "averageRecoverySeconds=\(averageSeconds)",
    ].joined(separator: "|")

    return FocusEvidencePacket(
      evidenceRevision: StableEvidenceRevision.make(from: canonical),
      primaryIndulgence: profile.primaryIndulgence,
      lifeDirections: directions,
      observationCount: count,
      dominantSource: source,
      dominantReason: reason,
      dominantBlockage: blockage,
      averageRecoverySeconds: averageSeconds
    )
  }
}

enum StableEvidenceRevision {
  static func make(from value: String) -> String {
    var hash: UInt64 = 14_695_981_039_346_656_037
    for byte in value.utf8 {
      hash ^= UInt64(byte)
      hash &*= 1_099_511_628_211
    }
    return String(hash, radix: 16)
  }
}

@MainActor
struct GroundedReflectionResolver {
  let service: any AppleIntelligenceServing

  func resolve(
    evidence: FocusEvidencePacket,
    repository: GeneratedStateRepository
  ) async -> AppleIntelligenceOperationState<PersonalReflection> {
    do {
      try repository.invalidateReflections(except: evidence.evidenceRevision)
      if let cached = try repository.reflection(for: evidence.evidenceRevision) {
        return .completed(cached)
      }

      guard service.capabilities.onDeviceIntelligence == .available else {
        return .completed(evidence.reflection(for: evidence.authoredSelection))
      }

      let selection = try await service.selectReflection(for: evidence)
      let reflection = evidence.reflection(for: selection)
      try repository.saveReflection(reflection)
      return .completed(reflection)
    } catch is CancellationError {
      return .cancelled
    } catch {
      return .failed
    }
  }
}
