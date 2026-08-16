import Testing

@testable import Indulge

struct AuthoredScenePresenterTests {
  @Test func standardMotionIsBoundedAndAmbient() {
    let plan = AuthoredSceneMotionPlan.resolve(reduceMotion: false, ambientMotion: true)

    #expect(plan.runsAmbientLoops)
    #expect(plan.breathingScale > 1)
    #expect(plan.breathingScale <= 1.02)
    #expect(plan.parallax <= 5)
    #expect(plan.lightDriftOpacity <= 0.35)
  }

  @Test func reducedMotionStopsLoopsAndUsesAnInPlaceCrossfade() {
    let plan = AuthoredSceneMotionPlan.resolve(reduceMotion: true, ambientMotion: true)

    #expect(!plan.runsAmbientLoops)
    #expect(plan.breathingScale == 1)
    #expect(plan.parallax == 0)
    #expect(plan.lightDriftOpacity == 0)
    #expect(plan.transitionDuration > 0)
  }

  @Test func semanticSummaryNamesVisibleCompanions() {
    #expect(
      OnboardingVisualState.watchingTelevision(phone: true, drink: true).semanticSummary
        == "A character sits on a sofa watching television, holding a phone, holding a drink."
    )
    #expect(OnboardingVisualState.gaming.semanticSummary.contains("controller"))
  }
}
