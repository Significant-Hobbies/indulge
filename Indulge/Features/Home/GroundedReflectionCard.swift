import SwiftData
import SwiftUI

struct GroundedReflectionCard: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \FocusInterruptionRecord.interruptedAt, order: .reverse) private var interruptions:
    [FocusInterruptionRecord]

  let profile: OnboardingProfile
  private let service: any AppleIntelligenceServing
  @State private var state = AppleIntelligenceOperationState<PersonalReflection>.idle

  init(
    profile: OnboardingProfile,
    service: any AppleIntelligenceServing = AppleIntelligenceServiceFactory.make()
  ) {
    self.profile = profile
    self.service = service
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label("A reflection from your evidence", systemImage: "sparkles")
        .font(.indulgeLabel)
        .foregroundStyle(Color.indulgeCherry)

      if let evidence {
        let fallback = evidence.reflection(for: evidence.authoredSelection)
        reflectionContent(displayedReflection(fallback: fallback))

        if case .working = state {
          ProgressView()
            .controlSize(.small)
            .accessibilityLabel("Considering your saved focus pattern")
        }
      } else {
        Text("Still learning your rhythm")
          .font(.indulgeTitle)
          .foregroundStyle(Color.indulgeText)
        Text(learningMessage)
          .font(.indulgeBody)
          .foregroundStyle(Color.indulgeText.opacity(0.66))
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      Color.indulgePowderSoft,
      in: RoundedRectangle(cornerRadius: 20, style: .continuous)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(Color.indulgePaleBorder.opacity(0.8))
    )
    .task(id: evidence?.evidenceRevision) {
      guard let evidence else {
        state = .idle
        return
      }
      state = .working
      state = await GroundedReflectionResolver(service: service).resolve(
        evidence: evidence,
        repository: GeneratedStateRepository(context: modelContext)
      )
    }
    .accessibilityElement(children: .combine)
  }

  @ViewBuilder
  private func reflectionContent(_ reflection: PersonalReflection) -> some View {
    Text(reflection.headline)
      .font(.indulgeTitle)
      .foregroundStyle(Color.indulgeText)
      .fixedSize(horizontal: false, vertical: true)
    Text(reflection.observation)
      .font(.indulgeBody)
      .foregroundStyle(Color.indulgeText.opacity(0.72))
      .fixedSize(horizontal: false, vertical: true)
    if let question = reflection.question {
      Text(question)
        .font(.indulgeBody)
        .foregroundStyle(Color.indulgeText.opacity(0.62))
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var evidence: FocusEvidencePacket? {
    FocusEvidenceBuilder.make(
      profile: profile,
      interruptions: interruptions.map(\.snapshot)
    )
  }

  private var learningMessage: String {
    guard
      case .learning(let remaining) =
        FocusSummary.aggregate(interruptions: interruptions.map(\.snapshot))
    else { return "Your saved pattern will appear here when it is ready." }
    return remaining == 1
      ? "One more complete interruption will make a first reflection possible."
      : "Complete \(remaining) interruptions to make a first reflection possible."
  }

  private func displayedReflection(fallback: PersonalReflection) -> PersonalReflection {
    if case .completed(let reflection) = state { return reflection }
    return fallback
  }
}
