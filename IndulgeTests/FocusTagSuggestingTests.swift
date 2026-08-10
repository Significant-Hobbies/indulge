import Testing

@testable import Indulge

struct FocusTagSuggestingTests {
  @Test func manualFallbackNeverInventsTags() async {
    let suggester = ManualFocusTagSuggester()

    #expect(suggester.availability == .unavailable)
    #expect(await suggester.suggestTags(for: "Slack arrived during a hard paragraph") == nil)
  }

  @Test func explicitChoicesRemainIndependentOfSuggestions() async {
    let explicitSource = FocusInterruptionSource.external
    let explicitReason = FocusInterruptionReason.message
    let failedSuggestion = await ManualFocusTagSuggester().suggestTags(for: "Opened video")

    #expect(failedSuggestion == nil)
    #expect(explicitSource == .external)
    #expect(explicitReason == .message)
  }
}
