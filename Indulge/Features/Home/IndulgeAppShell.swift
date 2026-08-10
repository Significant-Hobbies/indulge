import SwiftUI
import UIKit

enum IndulgeAppTab: String, CaseIterable, Equatable, Sendable {
  case life
  case focus
  case trade
  case history

  var title: String {
    switch self {
    case .life: "Life"
    case .focus: "Focus"
    case .trade: "Trade"
    case .history: "History"
    }
  }

  var icon: String {
    switch self {
    case .life: "house.fill"
    case .focus: "circle.dotted.circle.fill"
    case .trade: "arrow.left.arrow.right"
    case .history: "clock.fill"
    }
  }
}

enum ReclaimTarget: Int, CaseIterable, Equatable, Sendable {
  case fifteen = 15
  case thirty = 30
  case fortyFive = 45

  var title: String { "\(rawValue) min" }

  static func suggested(for time: DailyTime?) -> Self {
    switch time {
    case .underThirty, .none: .fifteen
    case .aboutOneHour: .fifteen
    case .twoHours: .thirty
    case .threePlus: .fortyFive
    }
  }
}

struct ActiveTrade: Equatable, Sendable {
  let indulgence: IndulgenceChoice
  let reclaimTarget: ReclaimTarget
  let destination: LifeDirection
}

struct IndulgeAppShell: View {
  let profile: OnboardingProfile
  let focusPreviewPreset: FocusPreviewPreset?
  @State private var selectedTab: IndulgeAppTab
  @State private var activeTrade: ActiveTrade?

  init(
    profile: OnboardingProfile, initialTab: IndulgeAppTab = .life,
    startsWithActiveTrade: Bool = false,
    focusPreviewPreset: FocusPreviewPreset? = nil
  ) {
    self.profile = profile
    self.focusPreviewPreset = focusPreviewPreset
    _selectedTab = State(initialValue: initialTab)
    _activeTrade = State(
      initialValue: startsWithActiveTrade ? Self.makeSuggestedTrade(for: profile) : nil)
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      LifeHomeView(profile: profile, activeTrade: activeTrade) {
        selectedTab = .trade
      }
      .tag(IndulgeAppTab.life)
      .tabItem { Label(IndulgeAppTab.life.title, systemImage: IndulgeAppTab.life.icon) }

      FocusHomeView(profile: profile, previewPreset: focusPreviewPreset)
        .tag(IndulgeAppTab.focus)
        .tabItem { Label(IndulgeAppTab.focus.title, systemImage: IndulgeAppTab.focus.icon) }

      TradeHomeView(profile: profile, activeTrade: $activeTrade)
        .tag(IndulgeAppTab.trade)
        .tabItem { Label(IndulgeAppTab.trade.title, systemImage: IndulgeAppTab.trade.icon) }

      HistoryHomeView(profile: profile, activeTrade: activeTrade) {
        selectedTab = .trade
      }
      .tag(IndulgeAppTab.history)
      .tabItem { Label(IndulgeAppTab.history.title, systemImage: IndulgeAppTab.history.icon) }
    }
    .tint(Color.indulgeCherry)
    .toolbarBackground(.visible, for: .tabBar)
    .toolbarBackground(Color.indulgeSurface, for: .tabBar)
  }

  static func makeSuggestedTrade(for profile: OnboardingProfile) -> ActiveTrade? {
    guard let indulgence = profile.primaryIndulgence else { return nil }
    let destination =
      LifeDirection.allCases.first(where: profile.lifeDirections.contains) ?? .presence
    return ActiveTrade(
      indulgence: indulgence,
      reclaimTarget: .suggested(for: profile.dailyTime),
      destination: destination
    )
  }
}

private struct LifeHomeView: View {
  let profile: OnboardingProfile
  let activeTrade: ActiveTrade?
  let openTrade: () -> Void
  @State private var showsAbout = false

  var body: some View {
    GeometryReader { viewport in
      NavigationStack {
        ScrollView {
          VStack(spacing: 0) {
            IndulgeSceneHeader(profile: profile, title: greeting, height: 380)

            VStack(alignment: .leading, spacing: 24) {
              VStack(alignment: .leading, spacing: 8) {
                Text("Your life, taking shape.")
                  .font(.indulgeDisplay)
                  .foregroundStyle(Color.indulgeText)
                  .fixedSize(horizontal: false, vertical: true)

                Text(patternSentence)
                  .font(.indulgeBody)
                  .foregroundStyle(Color.indulgeText.opacity(0.68))
                  .fixedSize(horizontal: false, vertical: true)
              }

              if let activeTrade {
                activeTradeSummary(activeTrade)
              } else {
                firstTradeInvitation
              }

              if !profile.lifeDirections.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                  Text("Making room for")
                    .font(.indulgeLabel)
                    .foregroundStyle(Color.indulgeText.opacity(0.58))

                  FlowingDirectionRow(directions: profile.lifeDirections)
                }
              }
            }
            .padding(.horizontal, 22)
            .padding(.top, 26)
            .padding(.bottom, 112)
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity)
            .background(Color.indulgeSurface)
            .clipShape(
              UnevenRoundedRectangle(
                topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
                topTrailingRadius: 30, style: .continuous)
            )
            .offset(y: -22)
          }
          .frame(width: viewport.size.width)
        }
        .background(Color.indulgePowderSoft)
        .ignoresSafeArea(edges: .top)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button { showsAbout = true } label: {
              Image(systemName: "person.crop.circle")
                .font(.system(size: 20, weight: .semibold))
            }
            .foregroundStyle(Color.indulgeText)
            .accessibilityLabel("About Indulge")
          }
        }
        .sheet(isPresented: $showsAbout) {
          IndulgeAboutView()
        }
      }
    }
  }

  private var greeting: String {
    profile.displayName == "you" ? "Your room" : "\(profile.displayName)’s room"
  }

  private var patternSentence: String {
    let indulgence = profile.primaryIndulgence?.title ?? "Your chosen indulgence"
    if let time = profile.dailyTime {
      return
        "\(indulgence) can hold \(time.reflectionText) of an ordinary day. Nothing here asks you to give it all up."
    }
    return "\(indulgence) is the first pattern you chose to understand."
  }

  private var firstTradeInvitation: some View {
    VStack(alignment: .leading, spacing: 15) {
      HStack(alignment: .top, spacing: 14) {
        Image(systemName: "arrow.left.arrow.right")
          .font(.system(size: 18, weight: .bold))
          .foregroundStyle(Color.indulgeCherry)
          .frame(width: 42, height: 42)
          .background(Color.indulgeCherry.opacity(0.09), in: Circle())

        VStack(alignment: .leading, spacing: 4) {
          Text("Make your first trade")
            .font(.indulgeTitle)
            .foregroundStyle(Color.indulgeText)
          Text("Keep the pleasure. Choose one small pocket of time to take back.")
            .font(.indulgeBody)
            .foregroundStyle(Color.indulgeText.opacity(0.64))
        }
      }

      Button("Create my first trade", action: openTrade)
        .buttonStyle(IndulgePrimaryLightButtonStyle())
    }
    .padding(18)
    .background(Color.indulgePowderSoft, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.indulgePaleBorder))
  }

  private func activeTradeSummary(_ trade: ActiveTrade) -> some View {
    HStack(spacing: 14) {
      TradeArtworkImage(assetName: trade.destination.artworkAssetName)
        .frame(width: 64, height: 64)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

      VStack(alignment: .leading, spacing: 3) {
        Text("Your first trade is ready")
          .font(.indulgeTitle)
          .foregroundStyle(Color.indulgeText)
        Text(
          "Keep \(trade.indulgence.title.lowercased()); guide \(trade.reclaimTarget.title.lowercased()) toward \(trade.destination.title.lowercased()) when it starts running on its own."
        )
        .font(.indulgeBody)
        .foregroundStyle(Color.indulgeText.opacity(0.64))
      }
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      Color.indulgeCherry.opacity(0.07), in: RoundedRectangle(cornerRadius: 20, style: .continuous)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(
        Color.indulgeCherry.opacity(0.36)))
  }
}

private struct IndulgeAboutView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      List {
        Section {
          VStack(alignment: .leading, spacing: 8) {
            Text("Keep the pleasure. Reclaim the time.")
              .font(.indulgeTitle)
              .foregroundStyle(Color.indulgeText)
            Text("Your profile, trades, and Focus journal stay on this device.")
              .font(.indulgeBody)
              .foregroundStyle(Color.indulgeText.opacity(0.68))
          }
          .padding(.vertical, 6)
        }

        Section("About") {
          Link("Privacy", destination: URL(string: "https://indulge.significanthobbies.com/privacy")!)
          Link("Support", destination: URL(string: "https://indulge.significanthobbies.com")!)
        }
      }
      .navigationTitle("Indulge")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
    .presentationDetents([.medium])
    .tint(Color.indulgeCherry)
  }
}

private struct TradeHomeView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  let profile: OnboardingProfile
  @Binding var activeTrade: ActiveTrade?
  @State private var target: ReclaimTarget
  @State private var destination: LifeDirection
  @State private var destinationFeedbackToken = 0

  init(profile: OnboardingProfile, activeTrade: Binding<ActiveTrade?>) {
    self.profile = profile
    _activeTrade = activeTrade
    _target = State(
      initialValue: activeTrade.wrappedValue?.reclaimTarget ?? .suggested(for: profile.dailyTime))
    let firstDirection =
      LifeDirection.allCases.first(where: profile.lifeDirections.contains) ?? .presence
    _destination = State(initialValue: activeTrade.wrappedValue?.destination ?? firstDirection)
  }

  var body: some View {
    GeometryReader { viewport in
      NavigationStack {
        ScrollView {
          VStack(spacing: 0) {
            IndulgeSceneHeader(
              profile: profile, title: activeTrade == nil ? "Your first trade" : "Trade active",
              height: 220)

            VStack(alignment: .leading, spacing: 20) {
              VStack(alignment: .leading, spacing: 8) {
                Text(
                  activeTrade == nil
                    ? "Trade a little drift for something you want."
                    : "Your time has somewhere to go."
                )
                .font(.indulgeDisplay)
                .foregroundStyle(Color.indulgeText)
                .fixedSize(horizontal: false, vertical: true)
                Text(
                  activeTrade == nil
                    ? "Keep the part you enjoy. Redirect only the time that stops feeling chosen."
                    : "Nothing is watched or blocked. Indulge remembers the exchange you chose."
                )
                .font(.indulgeBody)
                .foregroundStyle(Color.indulgeText.opacity(0.66))
              }

              VisualTradeExchange(
                indulgence: profile.primaryIndulgence,
                destination: activeTrade?.destination ?? destination,
                reclaimTarget: activeTrade?.reclaimTarget ?? target
              )

              if activeTrade == nil {
                VStack(alignment: .leading, spacing: 12) {
                  Text("What should that time become?")
                    .font(.indulgeTitle)
                    .foregroundStyle(Color.indulgeText)

                  ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                      ForEach(availableDestinations, id: \.self) { option in
                        destinationChoice(option)
                      }
                    }
                  }
                  .contentMargins(.horizontal, 1, for: .scrollContent)
                }

                VStack(alignment: .leading, spacing: 12) {
                  Text("How much starts there?")
                    .font(.indulgeTitle)
                    .foregroundStyle(Color.indulgeText)

                  HStack(spacing: 9) {
                    ForEach(ReclaimTarget.allCases, id: \.rawValue) { option in
                      Button {
                        target = option
                      } label: {
                        Text(option.title)
                          .font(.indulgeLabel)
                          .foregroundStyle(target == option ? .white : Color.indulgeText)
                          .frame(maxWidth: .infinity, minHeight: 48)
                          .background(
                            target == option ? Color.indulgeNavy : Color.indulgePowder,
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                      }
                      .buttonStyle(IndulgePressableButtonStyle())
                      .accessibilityAddTraits(target == option ? .isSelected : [])
                    }
                  }
                }

                Button("Create this trade") {
                  guard let indulgence = profile.primaryIndulgence else { return }
                  withAnimation(.smooth(duration: 0.42)) {
                    activeTrade = ActiveTrade(
                      indulgence: indulgence,
                      reclaimTarget: target,
                      destination: destination
                    )
                  }
                }
                .buttonStyle(IndulgePrimaryLightButtonStyle())
                .disabled(profile.primaryIndulgence == nil)
              } else if let activeTrade {
                Label(
                  "Guide \(activeTrade.reclaimTarget.title) toward \(activeTrade.destination.title.lowercased()) when the time stops feeling chosen.",
                  systemImage: "checkmark.circle.fill"
                )
                .font(.indulgeControl)
                .foregroundStyle(Color.indulgeText)
                .padding(17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                  Color.indulgeCherry.opacity(0.08),
                  in: RoundedRectangle(cornerRadius: 18, style: .continuous))
              }
            }
            .padding(.horizontal, 22)
            .padding(.top, 22)
            .padding(.bottom, 120)
            .frame(maxWidth: 680, alignment: .leading)
            .frame(maxWidth: .infinity)
            .background(Color.indulgeSurface)
            .clipShape(
              UnevenRoundedRectangle(
                topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
                topTrailingRadius: 30, style: .continuous)
            )
            .offset(y: -22)
          }
          .frame(width: viewport.size.width)
        }
        .background(Color.indulgePowderSoft)
        .ignoresSafeArea(edges: .top)
      }
    }
    .sensoryFeedback(.selection, trigger: destinationFeedbackToken)
  }

  private var availableDestinations: [LifeDirection] {
    let selected = LifeDirection.allCases.filter(profile.lifeDirections.contains)
    return selected.isEmpty ? LifeDirection.allCases : selected
  }

  private func destinationChoice(_ option: LifeDirection) -> some View {
    let selected = destination == option
    return Button {
      withAnimation(
        reduceMotion ? .easeInOut(duration: 0.16) : .spring(duration: 0.48, bounce: 0.14)
      ) {
        destination = option
      }
      destinationFeedbackToken += 1
    } label: {
      VStack(alignment: .leading, spacing: 8) {
        TradeArtworkImage(assetName: option.artworkAssetName)
          .frame(width: 100, height: 74)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          .overlay(alignment: .topTrailing) {
            if selected {
              Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.indulgeCherry, in: Circle())
                .padding(7)
            }
          }

        Text(option.title)
          .font(.indulgeCaption)
          .foregroundStyle(Color.indulgeText)
          .lineLimit(2)
          .frame(width: 100, alignment: .leading)
      }
      .padding(8)
      .background(
        selected ? Color.indulgeCherry.opacity(0.08) : Color.indulgePowderSoft,
        in: RoundedRectangle(cornerRadius: 20, style: .continuous)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(
          selected ? Color.indulgeCherry : Color.indulgePaleBorder))
    }
    .buttonStyle(IndulgePressableButtonStyle())
    .accessibilityAddTraits(selected ? .isSelected : [])
  }
}

private struct VisualTradeExchange: View {
  let indulgence: IndulgenceChoice?
  let destination: LifeDirection
  let reclaimTarget: ReclaimTarget

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 8) {
        exchangePanel(
          assetName: indulgence?.selectorAssetName ?? "television",
          label: "Keep",
          title: indulgence?.title ?? "Your pleasure"
        )

        exchangePanel(
          assetName: destination.artworkAssetName,
          label: "Make room for",
          title: destination.title
        )
        .id(destination)
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
      }
      .overlay {
        Image(systemName: "arrow.right")
          .font(.system(size: 14, weight: .black))
          .foregroundStyle(.white)
          .frame(width: 38, height: 38)
          .background(Color.indulgeNavy, in: Circle())
          .overlay(Circle().stroke(Color.white, lineWidth: 4))
          .accessibilityHidden(true)
      }

      Text(
        "\(reclaimTarget.title) moves toward \(destination.title.lowercased())—only when the time stops feeling chosen."
      )
      .font(.indulgeCaption)
      .foregroundStyle(Color.indulgeText.opacity(0.64))
      .fixedSize(horizontal: false, vertical: true)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(
      "Keep \(indulgence?.title ?? "your pleasure"). Move \(reclaimTarget.title) toward \(destination.title.lowercased()) when the time stops feeling chosen."
    )
  }

  private func exchangePanel(assetName: String, label: String, title: String) -> some View {
    ZStack(alignment: .bottomLeading) {
      TradeArtworkImage(assetName: assetName)

      LinearGradient(
        colors: [.clear, Color.indulgeNavy.opacity(0.82)],
        startPoint: .center,
        endPoint: .bottom
      )

      VStack(alignment: .leading, spacing: 1) {
        Text(label)
          .font(.indulgeCaption)
          .foregroundStyle(.white.opacity(0.82))
        Text(title)
          .font(.indulgeLabel)
          .foregroundStyle(.white)
          .lineLimit(2)
      }
      .padding(13)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 150)
    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
  }
}

private struct TradeArtworkImage: View {
  let assetName: String

  var body: some View {
    Group {
      if let source = UIImage(named: assetName, in: .main, compatibleWith: nil) {
        Image(uiImage: source)
          .resizable()
          .scaledToFill()
      } else {
        Color.indulgePowder
          .overlay {
            Image(systemName: "photo")
              .foregroundStyle(Color.indulgeText.opacity(0.4))
          }
      }
    }
    .clipped()
  }
}

private struct HistoryHomeView: View {
  let profile: OnboardingProfile
  let activeTrade: ActiveTrade?
  let openTrade: () -> Void

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        IndulgeSceneHeader(profile: profile, title: "Your history", height: 310)

        VStack(alignment: .leading, spacing: 18) {
          Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(Color.indulgeCherry)

          Text("Your history starts with a real trade.")
            .font(.indulgeDisplay)
            .foregroundStyle(Color.indulgeText)
            .fixedSize(horizontal: false, vertical: true)

          Text(
            activeTrade == nil
              ? "After your first trade, this is where you’ll see what you chose, what you reclaimed, and how the room changed. We won’t invent a chart before there is something true to show."
              : "Your trade is ready. When you complete it for the first time, its real story will appear here."
          )
          .font(.indulgeBody)
          .foregroundStyle(Color.indulgeText.opacity(0.66))
          .fixedSize(horizontal: false, vertical: true)

          if activeTrade == nil {
            Button("Create my first trade", action: openTrade)
              .buttonStyle(IndulgePrimaryLightButtonStyle())
          } else {
            Label("Waiting for your first completed trade", systemImage: "hourglass")
              .font(.indulgeControl)
              .foregroundStyle(Color.indulgeText)
              .padding(16)
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(
                Color.indulgePowderSoft, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
          }
          Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .frame(maxWidth: 680, maxHeight: .infinity, alignment: .topLeading)
        .frame(maxWidth: .infinity)
        .background(Color.indulgeSurface)
        .clipShape(
          UnevenRoundedRectangle(
            topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
            topTrailingRadius: 30, style: .continuous)
        )
        .offset(y: -22)
      }
      .background(Color.indulgePowderSoft)
      .ignoresSafeArea(edges: .top)
    }
  }
}

private struct IndulgeSceneHeader: View {
  let profile: OnboardingProfile
  let title: String
  let height: CGFloat

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        sceneImage
          .resizable()
          .scaledToFill()
          .frame(width: proxy.size.width, height: proxy.size.height)
          .clipped()
      }
    }
    .frame(height: height)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(title)
    .accessibilityValue(
      profile.primaryIndulgence.map { "Your scene for \($0.title.lowercased())" } ?? "Your room")
  }

  private var sceneImage: Image {
    let assetName = profile.visualState.sceneAssetName(for: profile.characterPresentation)
    guard let source = UIImage(named: assetName, in: .main, compatibleWith: nil) else {
      return Image(systemName: "photo")
    }
    return Image(uiImage: source)
  }
}

private struct FlowingDirectionRow: View {
  let directions: Set<LifeDirection>

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 9) {
        ForEach(directions.sorted { $0.rawValue < $1.rawValue }, id: \.self) { direction in
          Label(direction.title, systemImage: direction.icon)
            .font(.indulgeLabel)
            .foregroundStyle(Color.indulgeText)
            .padding(.horizontal, 13)
            .frame(minHeight: 44)
            .background(Color.indulgePowder, in: Capsule())
        }
      }
    }
  }
}

private struct IndulgePrimaryLightButtonStyle: ButtonStyle {
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

extension OnboardingProfile {
  static let appPreview = OnboardingProfile(
    preferredName: "Maya",
    gender: .woman,
    activities: [.television, .shortVideo, .alcohol],
    primaryIndulgence: .television,
    dailyTime: .twoHours,
    commonMoments: [.evening],
    startingPattern: .autopilot,
    need: .comfort,
    intentionality: .mixed,
    lifeDirections: [.presence, .creativity],
    pace: .gentle
  )
}

#Preview("Life app") {
  IndulgeAppShell(profile: .appPreview)
}

#Preview("Trade active") {
  IndulgeAppShell(profile: .appPreview, initialTab: .trade, startsWithActiveTrade: true)
}
