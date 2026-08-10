import SwiftData
import SwiftUI
import UIKit

enum FocusPreviewPreset: String, Equatable, Sendable {
  case idle
  case active
  case interrupted
  case populated
  case pattern
}

struct FocusHomeView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Query(sort: \FocusSessionRecord.startedAt, order: .reverse) private var sessions:
    [FocusSessionRecord]
  @Query(sort: \FocusInterruptionRecord.interruptedAt, order: .reverse) private var interruptions:
    [FocusInterruptionRecord]

  let profile: OnboardingProfile
  let previewPreset: FocusPreviewPreset?

  @State private var intention = ""
  @State private var presentedSheet: FocusSheet?
  @State private var errorMessage: String?
  @State private var feedbackToken = 0

  init(profile: OnboardingProfile, previewPreset: FocusPreviewPreset? = nil) {
    self.profile = profile
    self.previewPreset = previewPreset
  }

  var body: some View {
    GeometryReader { viewport in
      NavigationStack {
        ScrollView {
          VStack(spacing: 0) {
            FocusHero(
              profile: profile,
              isFocusing: activeSession != nil,
              isInterrupted: activeSession.flatMap(activeInterruption(for:)) != nil
            )

            VStack(alignment: .leading, spacing: 28) {
              TimelineView(.periodic(from: .now, by: 1)) { timeline in
                activeCard(now: timeline.date)
              }

              dailySection
              patternSection
              GroundedReflectionCard(profile: profile)
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .padding(.bottom, 116)
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity)
            .background(Color.indulgeSurface)
            .clipShape(
              UnevenRoundedRectangle(
                topLeadingRadius: 30,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 30,
                style: .continuous
              )
            )
            .offset(y: -24)
          }
          .frame(width: viewport.size.width)
        }
        .background(Color.indulgePowderSoft)
        .ignoresSafeArea(edges: .top)
        .alert("Focus could not be updated", isPresented: errorBinding) {
          Button("OK", role: .cancel) {}
        } message: {
          Text(errorMessage ?? "Please try again.")
        }
        .sheet(item: $presentedSheet) { sheet in
          switch sheet {
          case .classify(let id):
            if let interruption = interruptions.first(where: { $0.id == id }) {
              FocusReasonSheet(interruption: interruption) {
                feedbackToken += 1
              }
            }
          case .blockage(let id):
            if let interruption = interruptions.first(where: { $0.id == id }) {
              FocusBlockageSheet(interruption: interruption) {
                feedbackToken += 1
              }
            }
          }
        }
      }
    }
    .task {
      do {
        let repository = FocusRepository(context: modelContext)
        try repository.repairActiveRecords()
        try FocusPreviewSeeder.seedIfNeeded(
          previewPreset,
          context: modelContext
        )
      } catch {
        show(error)
      }
    }
    .sensoryFeedback(.selection, trigger: feedbackToken)
  }

  @ViewBuilder
  private func activeCard(now: Date) -> some View {
    VStack(alignment: .leading, spacing: 18) {
      if let session = activeSession {
        let interruption = activeInterruption(for: session)

        if dynamicTypeSize.isAccessibilitySize {
          VStack(alignment: .leading, spacing: 8) {
            sessionLabel(session: session, interruption: interruption)
            sessionClock(session: session, interruption: interruption, now: now)
          }
        } else {
          HStack(alignment: .firstTextBaseline, spacing: 12) {
            sessionLabel(session: session, interruption: interruption)
            Spacer(minLength: 8)
            sessionClock(session: session, interruption: interruption, now: now)
          }
        }

        FocusThreadView(isInterrupted: interruption != nil, reduceMotion: reduceMotion)
          .frame(height: 48)

        if let interruption {
          Text(
            interruption.isFullyClassified
              ? "Return when you are ready. We’ll capture what made returning difficult."
              : "The interruption is already saved. Add what pulled you away, then return when you can."
          )
          .font(.indulgeBody)
          .foregroundStyle(Color.indulgeText.opacity(0.66))
          .fixedSize(horizontal: false, vertical: true)

          if !interruption.isFullyClassified {
            Button("What pulled me away") {
              presentedSheet = .classify(interruption.id)
            }
            .buttonStyle(FocusPrimaryButtonStyle())
          }

          if interruption.isFullyClassified {
            Button("I’m back") {
              presentedSheet = .blockage(interruption.id)
            }
            .buttonStyle(FocusPrimaryButtonStyle())
          } else {
            Button("I’m back") {
              presentedSheet = .classify(interruption.id)
            }
            .buttonStyle(FocusSecondaryButtonStyle())
          }
        } else {
          Button {
            beginInterruption(in: session)
          } label: {
            Label("I was interrupted", systemImage: "scissors")
          }
          .buttonStyle(FocusPrimaryButtonStyle())
          .accessibilityHint("Saves the interruption immediately")

          Button("End focus session") {
            endSession(session)
          }
          .buttonStyle(FocusSecondaryButtonStyle())
        }
      } else {
        Text("Protect the thread.")
          .font(.indulgeDisplay)
          .foregroundStyle(Color.indulgeText)

        Text("Begin when you want to notice what actually breaks your attention.")
          .font(.indulgeBody)
          .foregroundStyle(Color.indulgeText.opacity(0.66))
          .fixedSize(horizontal: false, vertical: true)

        FocusThreadView(isInterrupted: false, reduceMotion: true)
          .frame(height: 48)

        VStack(alignment: .leading, spacing: 7) {
          Text("Focus intention (optional)")
            .font(.indulgeLabel)
            .foregroundStyle(Color.indulgeText)
          TextField("For example: finish the product brief", text: $intention)
            .font(.indulgeBody)
            .textInputAutocapitalization(.sentences)
            .submitLabel(.go)
            .padding(.horizontal, 16)
            .frame(minHeight: 54)
            .background(
              Color.indulgeSurface,
              in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
              RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.indulgePaleBorder)
            )
            .onSubmit(startSession)
        }

        Button("Start focus", action: startSession)
          .buttonStyle(FocusPrimaryButtonStyle())
      }
    }
    .padding(20)
    .background(
      Color.indulgePowderSoft,
      in: RoundedRectangle(cornerRadius: 24, style: .continuous)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .stroke(Color.indulgePaleBorder.opacity(0.85))
    )
  }

  private var dailySection: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Each day")
        .font(.indulgeTitle)
        .foregroundStyle(Color.indulgeText)

      if daySummaries.isEmpty {
        Text("Your interruption count and recovery time will appear after your first session.")
          .font(.indulgeBody)
          .foregroundStyle(Color.indulgeText.opacity(0.6))
          .padding(18)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            Color.indulgePowderSoft,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
          )
      } else {
        VStack(spacing: 0) {
          ForEach(Array(daySummaries.prefix(7).enumerated()), id: \.element.id) { index, day in
            FocusDayRow(day: day)
            if index < min(daySummaries.count, 7) - 1 {
              Divider().padding(.leading, 58)
            }
          }
        }
        .padding(.horizontal, 16)
        .background(
          Color.indulgePowderSoft,
          in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .stroke(Color.indulgePaleBorder.opacity(0.75))
        )
      }
    }
  }

  private var patternSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("What keeps happening", systemImage: "point.3.filled.connected.trianglepath.dotted")
        .font(.indulgeTitle)
        .foregroundStyle(Color.indulgeText)

      switch aggregateInsight {
      case .learning(let remaining):
        Text(
          remaining == 1
            ? "One more complete interruption will give us enough evidence for a first pattern."
            : "Complete \(remaining) interruptions to reveal a pattern."
        )
        .font(.indulgeBody)
        .foregroundStyle(Color.indulgeText.opacity(0.66))
      case .pattern(_, let reason, let blockage, let averageRecovery, let count):
        Text(
          "Across \(count) interruptions, \(reason.patternPhrase) appeared most often. \(blockage.shortTitle) most often slowed the return, with \(FocusTimeText.concise(averageRecovery)) average recovery."
        )
        .font(.indulgeBody)
        .foregroundStyle(Color.indulgeText.opacity(0.72))
      }
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      Color.indulgeCherry.opacity(0.065),
      in: RoundedRectangle(cornerRadius: 20, style: .continuous)
    )
  }

  private var activeSession: FocusSessionRecord? {
    sessions.first(where: { $0.endedAt == nil })
  }

  private func sessionLabel(
    session: FocusSessionRecord,
    interruption: FocusInterruptionRecord?
  ) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(interruption == nil ? "Your thread is holding." : "Your thread is open.")
        .font(.indulgeQuestion)
        .foregroundStyle(Color.indulgeText)
        .fixedSize(horizontal: false, vertical: true)
      Text(session.intention.isEmpty ? "Focused time" : session.intention)
        .font(.indulgeLabel)
        .foregroundStyle(Color.indulgeText.opacity(0.58))
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private func sessionClock(
    session: FocusSessionRecord,
    interruption: FocusInterruptionRecord?,
    now: Date
  ) -> some View {
    Text(
      FocusTimeText.clock(
        from: interruption?.interruptedAt ?? session.startedAt,
        to: now
      )
    )
    .font(.system(.title3, design: .rounded, weight: .bold))
    .monospacedDigit()
    .foregroundStyle(interruption == nil ? Color.indulgeText : Color.indulgeCherry)
    .accessibilityLabel(interruption == nil ? "Focus duration" : "Recovery duration")
    .accessibilityValue(
      FocusTimeText.clock(
        from: interruption?.interruptedAt ?? session.startedAt,
        to: now
      )
    )
  }

  private func activeInterruption(for session: FocusSessionRecord) -> FocusInterruptionRecord? {
    interruptions.first(where: { $0.sessionID == session.id && $0.returnedAt == nil })
  }

  private var daySummaries: [FocusDaySummary] {
    FocusSummary.days(
      sessions: sessions.map(\.snapshot),
      interruptions: interruptions.map(\.snapshot)
    )
  }

  private var aggregateInsight: FocusAggregateInsight {
    FocusSummary.aggregate(interruptions: interruptions.map(\.snapshot))
  }

  private var errorBinding: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { if !$0 { errorMessage = nil } }
    )
  }

  private func startSession() {
    do {
      _ = try FocusRepository(context: modelContext).startSession(intention: intention)
      intention = ""
      feedbackToken += 1
    } catch {
      show(error)
    }
  }

  private func beginInterruption(in session: FocusSessionRecord) {
    do {
      let interruption = try FocusRepository(context: modelContext).beginInterruption(in: session)
      feedbackToken += 1
      presentedSheet = .classify(interruption.id)
    } catch {
      show(error)
    }
  }

  private func endSession(_ session: FocusSessionRecord) {
    do {
      try FocusRepository(context: modelContext).endSession(session)
      feedbackToken += 1
    } catch {
      show(error)
    }
  }

  private func show(_ error: Error) {
    errorMessage = error.localizedDescription
  }
}

private enum FocusSheet: Identifiable {
  case classify(UUID)
  case blockage(UUID)

  var id: String {
    switch self {
    case .classify(let id): "classify-\(id)"
    case .blockage(let id): "blockage-\(id)"
    }
  }
}

private struct FocusHero: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  let profile: OnboardingProfile
  let isFocusing: Bool
  let isInterrupted: Bool

  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .bottomLeading) {
        Group {
          if let image = UIImage(named: sceneAssetName, in: .main, compatibleWith: nil) {
            Image(uiImage: image)
              .resizable()
              .scaledToFill()
          } else {
            Color.indulgePowder
          }
        }
        .frame(width: proxy.size.width, height: heroHeight)
        .clipped()

        LinearGradient(
          colors: [.clear, Color.indulgeNavy.opacity(0.82)],
          startPoint: .center,
          endPoint: .bottom
        )

        VStack(alignment: .leading, spacing: 3) {
          Text("FOCUS")
            .font(.indulgeWordmark)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .tracking(2.2)
            .foregroundStyle(.white.opacity(0.72))
          Text(heroTitle)
            .font(.indulgeQuestion)
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 48)
        .frame(width: proxy.size.width, alignment: .leading)
      }
      .frame(width: proxy.size.width, height: heroHeight)
      .clipped()
    }
    .frame(height: heroHeight)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(
      isFocusing
        ? "\(profile.displayName)’s focus session is active"
        : "Focus interruption journal"
    )
  }

  private var heroTitle: String {
    if isInterrupted { return "Find your way back." }
    return isFocusing ? "Stay with the thread." : "See what breaks the thread."
  }

  private var heroHeight: CGFloat {
    dynamicTypeSize.isAccessibilitySize ? 330 : 270
  }

  private var sceneAssetName: String {
    profile.visualState.sceneAssetName(for: profile.characterPresentation)
  }
}

private struct FocusThreadView: View {
  let isInterrupted: Bool
  let reduceMotion: Bool
  @State private var travels = false

  var body: some View {
    GeometryReader { proxy in
      let midY = proxy.size.height / 2
      let gap: CGFloat = isInterrupted ? 42 : 0
      let center = proxy.size.width * 0.62

      ZStack(alignment: .leading) {
        Path { path in
          path.move(to: CGPoint(x: 0, y: midY))
          path.addCurve(
            to: CGPoint(x: center - gap / 2, y: midY),
            control1: CGPoint(x: proxy.size.width * 0.18, y: 4),
            control2: CGPoint(x: proxy.size.width * 0.38, y: proxy.size.height - 4)
          )
          if isInterrupted {
            path.move(to: CGPoint(x: center + gap / 2, y: midY))
          }
          path.addCurve(
            to: CGPoint(x: proxy.size.width, y: midY),
            control1: CGPoint(x: proxy.size.width * 0.78, y: 5),
            control2: CGPoint(x: proxy.size.width * 0.9, y: proxy.size.height - 3)
          )
        }
        .stroke(
          isInterrupted ? Color.indulgeCherry : Color.indulgeText,
          style: StrokeStyle(lineWidth: 4, lineCap: .round)
        )

        if !isInterrupted {
          Circle()
            .fill(Color.indulgeCherry)
            .frame(width: 11, height: 11)
            .offset(x: travels ? max(0, proxy.size.width - 11) : 0)
            .animation(
              reduceMotion
                ? nil
                : .easeInOut(duration: 2.4).repeatForever(autoreverses: true),
              value: travels
            )
        } else {
          Image(systemName: "scissors")
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(Color.indulgeCherry)
            .frame(width: 30, height: 30)
            .background(Color.indulgeSurface, in: Circle())
            .offset(x: center - 15)
        }
      }
    }
    .onAppear { travels = true }
    .accessibilityHidden(true)
  }
}

private struct FocusDayRow: View {
  let day: FocusDaySummary

  var body: some View {
    HStack(spacing: 13) {
      VStack(spacing: 0) {
        Text(day.day.formatted(.dateTime.day()))
          .font(.system(.title3, design: .rounded, weight: .bold))
        Text(day.day.formatted(.dateTime.month(.abbreviated)))
          .font(.indulgeCaption)
      }
      .foregroundStyle(Color.indulgeText)
      .frame(width: 42, height: 48)
      .background(Color.indulgeSurface, in: RoundedRectangle(cornerRadius: 13, style: .continuous))

      VStack(alignment: .leading, spacing: 3) {
        Text(interruptionTitle)
          .font(.indulgeLabel)
          .foregroundStyle(Color.indulgeText)

        Text(detailText)
          .font(.indulgeCaption)
          .foregroundStyle(Color.indulgeText.opacity(0.6))
          .lineLimit(2)
      }
      Spacer(minLength: 0)
    }
    .padding(.vertical, 12)
    .accessibilityElement(children: .combine)
  }

  private var interruptionTitle: String {
    if day.interruptionCount == 0 && day.recoveryDuration > 0 {
      return "No new interruptions"
    }
    return
      "\(day.interruptionCount) \(day.interruptionCount == 1 ? "interruption" : "interruptions")"
  }

  private var detailText: String {
    let focused = "\(FocusTimeText.concise(day.focusedDuration)) focused"
    let recovery = "\(FocusTimeText.concise(day.recoveryDuration)) recovery"
    if day.interruptionCount == 0 && day.recoveryDuration > 0 {
      return "\(focused) · \(recovery) carried over"
    }
    return "\(focused) · \(recovery)"
  }
}

private struct FocusReasonSheet: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  let interruption: FocusInterruptionRecord
  let onSaved: () -> Void

  @State private var source: FocusInterruptionSource?
  @State private var reason: FocusInterruptionReason?
  @State private var note: String
  @State private var suggesting = false
  @State private var errorMessage: String?
  private let intelligenceService: any AppleIntelligenceServing

  init(interruption: FocusInterruptionRecord, onSaved: @escaping () -> Void) {
    self.interruption = interruption
    self.onSaved = onSaved
    _source = State(initialValue: interruption.source)
    _reason = State(initialValue: interruption.reason)
    _note = State(initialValue: interruption.note)
    intelligenceService = AppleIntelligenceServiceFactory.make()
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          VStack(alignment: .leading, spacing: 7) {
            Text("What pulled you away?")
              .font(.indulgeDisplay)
              .foregroundStyle(Color.indulgeText)
            Text("The interruption is already saved.")
              .font(.indulgeBody)
              .foregroundStyle(Color.indulgeText.opacity(0.6))
          }

          VStack(alignment: .leading, spacing: 10) {
            Text("Where did it come from?")
              .font(.indulgeTitle)
              .foregroundStyle(Color.indulgeText)
            ForEach(FocusInterruptionSource.allCases, id: \.self) { option in
              FocusChoiceButton(
                title: option.title,
                subtitle: option.prompt,
                icon: option.icon,
                selected: source == option
              ) {
                source = option
              }
            }
          }

          VStack(alignment: .leading, spacing: 10) {
            Text("What happened?")
              .font(.indulgeTitle)
              .foregroundStyle(Color.indulgeText)
            ForEach(FocusInterruptionReason.allCases, id: \.self) { option in
              FocusChoiceButton(
                title: option.title,
                icon: option.icon,
                selected: reason == option
              ) {
                reason = option
              }
            }
          }

          VStack(alignment: .leading, spacing: 9) {
            Text("A few words, if useful")
              .font(.indulgeTitle)
              .foregroundStyle(Color.indulgeText)
            TextField("For example: opened YouTube after a hard bug", text: $note, axis: .vertical)
              .lineLimit(2...4)
              .padding(15)
              .background(
                Color.indulgePowderSoft,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
              )

            if intelligenceService.capabilities.onDeviceIntelligence == .available && !note.isEmpty
            {
              Button {
                Task { await suggestTags() }
              } label: {
                Label(suggesting ? "Suggesting…" : "Suggest tags", systemImage: "sparkles")
              }
              .font(.indulgeLabel)
              .foregroundStyle(Color.indulgeCherry)
              .disabled(suggesting)
            }
          }

          Button("Save reason") {
            guard let source, let reason else { return }
            do {
              try FocusRepository(context: modelContext).classify(
                interruption,
                source: source,
                reason: reason,
                note: note
              )
              onSaved()
              dismiss()
            } catch {
              errorMessage = error.localizedDescription
            }
          }
          .buttonStyle(FocusPrimaryButtonStyle())
          .disabled(source == nil || reason == nil)
        }
        .padding(22)
        .padding(.bottom, 24)
      }
      .background(Color.indulgeSurface)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Close") { dismiss() }
            .foregroundStyle(Color.indulgeText)
        }
      }
      .alert("Reason was not saved", isPresented: errorBinding) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(errorMessage ?? "Please try again.")
      }
    }
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
  }

  private func suggestTags() async {
    suggesting = true
    defer { suggesting = false }
    do {
      guard let suggestion = try await intelligenceService.suggestTags(for: note) else { return }
      if source == nil { source = suggestion.source }
      if reason == nil { reason = suggestion.reason }
    } catch is CancellationError {
      return
    } catch {
      errorMessage = "Suggestions are unavailable right now. Your choices are unchanged."
    }
  }

  private var errorBinding: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { if !$0 { errorMessage = nil } }
    )
  }
}

private struct FocusBlockageSheet: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss

  let interruption: FocusInterruptionRecord
  let onSaved: () -> Void
  @State private var blockage: FocusReturnBlockage?
  @State private var errorMessage: String?

  init(interruption: FocusInterruptionRecord, onSaved: @escaping () -> Void) {
    self.interruption = interruption
    self.onSaved = onSaved
    _blockage = State(initialValue: interruption.blockage)
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 22) {
          VStack(alignment: .leading, spacing: 7) {
            Text("What made returning hard?")
              .font(.indulgeDisplay)
              .foregroundStyle(Color.indulgeText)
            Text("Choose the closest answer. This is about recovery—not blame.")
              .font(.indulgeBody)
              .foregroundStyle(Color.indulgeText.opacity(0.62))
          }

          VStack(spacing: 10) {
            ForEach(FocusReturnBlockage.allCases, id: \.self) { option in
              FocusChoiceButton(
                title: option.title,
                icon: option.icon,
                selected: blockage == option
              ) {
                blockage = option
              }
            }
          }

          Button("Return to focus") {
            guard let blockage else { return }
            do {
              try FocusRepository(context: modelContext).returnToFocus(
                from: interruption,
                blockage: blockage
              )
              onSaved()
              dismiss()
            } catch {
              errorMessage = error.localizedDescription
            }
          }
          .buttonStyle(FocusPrimaryButtonStyle())
          .disabled(blockage == nil)
        }
        .padding(22)
        .padding(.bottom, 24)
      }
      .background(Color.indulgeSurface)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Close") { dismiss() }
            .foregroundStyle(Color.indulgeText)
        }
      }
      .alert("Return was not saved", isPresented: errorBinding) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(errorMessage ?? "Please try again.")
      }
    }
    .presentationDetents([.large])
    .presentationDragIndicator(.visible)
  }

  private var errorBinding: Binding<Bool> {
    Binding(
      get: { errorMessage != nil },
      set: { if !$0 { errorMessage = nil } }
    )
  }
}

private struct FocusChoiceButton: View {
  let title: String
  var subtitle: String? = nil
  let icon: String
  let selected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 13) {
        Image(systemName: icon)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(selected ? .white : Color.indulgeText)
          .frame(width: 38, height: 38)
          .background(selected ? Color.indulgeCherry : Color.indulgePowder, in: Circle())

        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .font(.indulgeLabel)
          if let subtitle {
            Text(subtitle)
              .font(.indulgeCaption)
              .opacity(0.62)
          }
        }
        .foregroundStyle(Color.indulgeText)
        .multilineTextAlignment(.leading)

        Spacer(minLength: 8)
        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(selected ? Color.indulgeCherry : Color.indulgePaleBorder)
      }
      .padding(13)
      .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
      .background(
        selected ? Color.indulgeCherry.opacity(0.065) : Color.indulgePowderSoft,
        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .stroke(selected ? Color.indulgeCherry : Color.indulgePaleBorder)
      )
    }
    .buttonStyle(IndulgePressableButtonStyle())
    .accessibilityAddTraits(selected ? .isSelected : [])
  }
}

private struct FocusPrimaryButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.indulgeControl)
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity, minHeight: 56)
      .background(
        Color.indulgeCherry,
        in: RoundedRectangle(cornerRadius: IndulgeTheme.cornerRadius, style: .continuous)
      )
      .opacity(isEnabled ? 1 : 0.42)
      .scaleEffect(configuration.isPressed && !reduceMotion ? 0.985 : 1)
      .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
  }
}

private struct FocusSecondaryButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.indulgeControl)
      .foregroundStyle(Color.indulgeText)
      .frame(maxWidth: .infinity, minHeight: 52)
      .background(
        Color.indulgeSurface,
        in: RoundedRectangle(cornerRadius: IndulgeTheme.cornerRadius, style: .continuous)
      )
      .overlay(
        RoundedRectangle(cornerRadius: IndulgeTheme.cornerRadius, style: .continuous)
          .stroke(Color.indulgePaleBorder)
      )
      .opacity(configuration.isPressed ? 0.72 : 1)
  }
}

enum FocusTimeText {
  static func clock(from start: Date, to end: Date) -> String {
    let seconds = max(0, Int(end.timeIntervalSince(start)))
    let hours = seconds / 3_600
    let minutes = (seconds % 3_600) / 60
    let remainder = seconds % 60
    return hours > 0
      ? String(format: "%d:%02d:%02d", hours, minutes, remainder)
      : String(format: "%02d:%02d", minutes, remainder)
  }

  static func concise(_ interval: TimeInterval) -> String {
    let minutes = max(0, Int(interval.rounded() / 60))
    if interval <= 0 { return "0 min" }
    if minutes < 1 { return "under 1 min" }
    if minutes < 60 { return "\(minutes) min" }
    let hours = minutes / 60
    let remainder = minutes % 60
    return remainder == 0 ? "\(hours)h" : "\(hours)h \(remainder)m"
  }
}

@MainActor
private enum FocusPreviewSeeder {
  static func seedIfNeeded(
    _ preset: FocusPreviewPreset?,
    context: ModelContext,
    now: Date = .now
  ) throws {
    guard let preset, preset != .idle else { return }
    guard try FocusRepository(context: context).sessions().isEmpty else { return }

    let calendar = Calendar.autoupdatingCurrent
    func ago(minutes: Int) -> Date {
      calendar.date(byAdding: .minute, value: -minutes, to: now) ?? now
    }

    if preset == .active || preset == .interrupted {
      let session = FocusSessionRecord(
        intention: "Shape the next Indulge screen", startedAt: ago(minutes: 24))
      context.insert(session)
      if preset == .interrupted {
        context.insert(
          FocusInterruptionRecord(
            sessionID: session.id,
            interruptedAt: ago(minutes: 4),
            source: .drift,
            reason: .temptingApp,
            note: "Opened YouTube after a difficult decision"
          )
        )
      }
      try context.save()
      return
    }

    let observations:
      [(Int, Int, FocusInterruptionSource, FocusInterruptionReason, FocusReturnBlockage)] = [
        (70, 18, .drift, .temptingApp, .temptingContent),
        (1_540, 9, .external, .message, .urgentDemand),
        (2_930, 25, .drift, .temptingApp, .temptingContent),
        (4_400, 13, .environment, .bodyNeed, .fatigue),
      ]
    let selected = preset == .pattern ? observations : Array(observations.prefix(2))
    for (startMinutes, recoveryMinutes, source, reason, blockage) in selected {
      let sessionStart = ago(minutes: startMinutes)
      let authoredEnd =
        calendar.date(byAdding: .minute, value: 95, to: sessionStart) ?? sessionStart
      let sessionEnd = min(authoredEnd, ago(minutes: 5))
      let session = FocusSessionRecord(
        intention: "Focused work",
        startedAt: sessionStart,
        endedAt: sessionEnd
      )
      context.insert(session)
      let interruptedAt =
        calendar.date(byAdding: .minute, value: 31, to: sessionStart) ?? sessionStart
      let returnedAt = calendar.date(byAdding: .minute, value: recoveryMinutes, to: interruptedAt)
      context.insert(
        FocusInterruptionRecord(
          sessionID: session.id,
          interruptedAt: interruptedAt,
          returnedAt: returnedAt,
          source: source,
          reason: reason,
          blockage: blockage
        )
      )
    }
    try context.save()
  }
}
