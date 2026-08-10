import Foundation

struct FocusTagSuggestion: Equatable, Sendable {
  let source: FocusInterruptionSource
  let reason: FocusInterruptionReason
  let blockage: FocusReturnBlockage?
}

enum FocusTaggerAvailability: Equatable, Sendable {
  case available
  case unavailable
}

protocol FocusTagSuggesting: Sendable {
  var availability: FocusTaggerAvailability { get }
  func suggestTags(for note: String) async -> FocusTagSuggestion?
}

struct ManualFocusTagSuggester: FocusTagSuggesting {
  let availability = FocusTaggerAvailability.unavailable

  func suggestTags(for note: String) async -> FocusTagSuggestion? {
    nil
  }
}

#if canImport(FoundationModels)
  import FoundationModels

  @available(iOS 26.0, *)
  struct AppleFocusTagSuggester: FocusTagSuggesting {
    private let model = SystemLanguageModel(useCase: .contentTagging)

    var availability: FocusTaggerAvailability {
      model.availability == .available ? .available : .unavailable
    }

    func suggestTags(for note: String) async -> FocusTagSuggestion? {
      let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty, availability == .available else { return nil }

      do {
        let session = LanguageModelSession(
          model: model,
          instructions: """
            Classify one private note about a focus interruption. Return only the generated fields. \
            Use the exact raw values described in the schema. Do not diagnose, judge, or add advice.
            """
        )
        let response = try await session.respond(
          to: "Interruption note: \(trimmed)",
          generating: GeneratedFocusTagSuggestion.self
        )
        guard
          let source = FocusInterruptionSource(rawValue: response.content.source),
          let reason = FocusInterruptionReason(rawValue: response.content.reason)
        else { return nil }

        return FocusTagSuggestion(
          source: source,
          reason: reason,
          blockage: response.content.blockage.flatMap(FocusReturnBlockage.init(rawValue:))
        )
      } catch {
        return nil
      }
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
#endif

enum FocusTagSuggesterFactory {
  static func make() -> any FocusTagSuggesting {
    #if canImport(FoundationModels)
      if #available(iOS 26.0, *) {
        let apple = AppleFocusTagSuggester()
        if apple.availability == .available { return apple }
      }
    #endif
    return ManualFocusTagSuggester()
  }
}
