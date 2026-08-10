import Testing

@testable import Indulge

struct FocusTagSuggestingTests {
  @Test func manualFallbackNeverInventsTags() async {
    let service = ManualAppleIntelligenceService()
    let suggestion = try? await service.suggestTags(
      for: "Slack arrived during a hard paragraph")

    #expect(service.capabilities.onDeviceIntelligence == .unavailable)
    #expect(suggestion == nil)
  }

  @Test func explicitChoicesRemainIndependentOfSuggestions() async {
    let explicitSource = FocusInterruptionSource.external
    let explicitReason = FocusInterruptionReason.message
    let failedSuggestion = try? await ManualAppleIntelligenceService().suggestTags(
      for: "Opened video")

    #expect(failedSuggestion == nil)
    #expect(explicitSource == .external)
    #expect(explicitReason == .message)
  }
}
