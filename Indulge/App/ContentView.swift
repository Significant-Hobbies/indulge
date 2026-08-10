import Foundation
import SwiftData
import SwiftUI

struct ContentView: View {
  private let route: IndulgeLaunchRoute
  private let profileStore: OnboardingProfileStore
  @Query(filter: #Predicate<FocusSessionRecord> { $0.endedAt == nil })
  private var activeFocusSessions: [FocusSessionRecord]
  @State private var completedProfile: OnboardingProfile?

  init(
    route: IndulgeLaunchRoute = .launchArguments,
    profileStore: OnboardingProfileStore = OnboardingProfileStore()
  ) {
    self.route = route
    self.profileStore = profileStore
    let restoredProfile = route == .automatic ? profileStore.load() : nil
    _completedProfile = State(
      initialValue: route.opensApplication ? .appPreview : restoredProfile
    )
  }

  var body: some View {
    if route == .review {
      IndulgeReviewView()
    } else if let completedProfile {
      IndulgeAppShell(
        profile: completedProfile,
        initialTab: initialTab,
        startsWithActiveTrade: route.startsWithActiveTrade,
        focusPreviewPreset: route.focusPreviewPreset
      )
    } else {
      IndulgeOnboardingView { profile in
        profileStore.save(profile)
        withAnimation(.smooth(duration: 0.55)) {
          completedProfile = profile
        }
      }
    }
  }

  private var initialTab: IndulgeAppTab {
    route.initialTab(hasActiveFocusSession: !activeFocusSessions.isEmpty)
  }
}

enum IndulgeLaunchRoute: Equatable, Sendable {
  case automatic
  case onboarding
  case application(tab: IndulgeAppTab, activeTrade: Bool, focusPreview: FocusPreviewPreset? = nil)
  case review

  static var launchArguments: Self {
    resolve(arguments: ProcessInfo.processInfo.arguments)
  }

  static func resolve(arguments: [String]) -> Self {
    if arguments.contains("--review") { return .review }
    if arguments.contains("--app-focus-pattern") {
      return .application(tab: .focus, activeTrade: false, focusPreview: .pattern)
    }
    if arguments.contains("--app-focus-populated") {
      return .application(tab: .focus, activeTrade: false, focusPreview: .populated)
    }
    if arguments.contains("--app-focus-interrupted") {
      return .application(tab: .focus, activeTrade: false, focusPreview: .interrupted)
    }
    if arguments.contains("--app-focus-active") {
      return .application(tab: .focus, activeTrade: false, focusPreview: .active)
    }
    if arguments.contains("--app-focus") {
      return .application(tab: .focus, activeTrade: false, focusPreview: .idle)
    }
    if arguments.contains("--app-trade-active") {
      return .application(tab: .trade, activeTrade: true)
    }
    if arguments.contains("--app-trade") { return .application(tab: .trade, activeTrade: false) }
    if arguments.contains("--app-history") {
      return .application(tab: .history, activeTrade: false)
    }
    if arguments.contains("--app-life") { return .application(tab: .life, activeTrade: false) }
    if arguments.contains("--onboarding") { return .onboarding }
    return .automatic
  }

  var opensApplication: Bool {
    if case .application = self { return true }
    return false
  }

  var initialTab: IndulgeAppTab {
    if case .application(let tab, _, _) = self { return tab }
    return .life
  }

  func initialTab(hasActiveFocusSession: Bool) -> IndulgeAppTab {
    if self == .automatic, hasActiveFocusSession { return .focus }
    return initialTab
  }

  var startsWithActiveTrade: Bool {
    if case .application(_, let activeTrade, _) = self { return activeTrade }
    return false
  }

  var focusPreviewPreset: FocusPreviewPreset? {
    if case .application(_, _, let preset) = self { return preset }
    return nil
  }
}

struct OnboardingProfileStore {
  private static let key = "completed-onboarding-profile-v1"
  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func load() -> OnboardingProfile? {
    guard let data = defaults.data(forKey: Self.key) else { return nil }
    return try? JSONDecoder().decode(OnboardingProfile.self, from: data)
  }

  func save(_ profile: OnboardingProfile) {
    guard let data = try? JSONEncoder().encode(profile) else { return }
    defaults.set(data, forKey: Self.key)
  }
}

#Preview("Onboarding") {
  ContentView(route: .onboarding)
}

#Preview("Life") {
  ContentView(route: .application(tab: .life, activeTrade: false))
}

#Preview("Focus pattern") {
  ContentView(route: .application(tab: .focus, activeTrade: false, focusPreview: .pattern))
}
