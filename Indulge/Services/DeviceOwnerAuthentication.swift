import Foundation
import LocalAuthentication

enum DeviceOwnerAuthenticationAvailability: Equatable, Sendable {
  case available
  case unavailable
}

enum DeviceOwnerAuthenticationOutcome: Equatable, Sendable {
  case authenticated
  case cancelled
  case failed
}

@MainActor
protocol DeviceOwnerAuthenticating {
  var availability: DeviceOwnerAuthenticationAvailability { get }
  func authenticate(reason: String) async -> DeviceOwnerAuthenticationOutcome
}

@MainActor
struct LocalDeviceOwnerAuthenticationService: DeviceOwnerAuthenticating {
  static let policy = LAPolicy.deviceOwnerAuthentication

  var availability: DeviceOwnerAuthenticationAvailability {
    let context = LAContext()
    var error: NSError?
    return context.canEvaluatePolicy(Self.policy, error: &error)
      ? .available : .unavailable
  }

  func authenticate(reason: String) async -> DeviceOwnerAuthenticationOutcome {
    let context = LAContext()
    context.localizedCancelTitle = "Not now"
    do {
      let authenticated = try await context.evaluatePolicy(
        Self.policy,
        localizedReason: reason
      )
      return authenticated ? .authenticated : .failed
    } catch let error as LAError {
      switch error.code {
      case .appCancel, .systemCancel, .userCancel:
        return .cancelled
      default:
        return .failed
      }
    } catch {
      return .failed
    }
  }
}

@MainActor
protocol PrivacyLockStoring: AnyObject {
  var isEnabled: Bool { get set }
  var relockAfter: TimeInterval { get set }
}

@MainActor
final class PrivacyLockSettingsStore: PrivacyLockStoring {
  static let enabledKey = "privacy-lock-enabled-v1"
  static let relockAfterKey = "privacy-lock-relock-after-v1"
  static let defaultRelockAfter: TimeInterval = 0

  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  var isEnabled: Bool {
    get { defaults.bool(forKey: Self.enabledKey) }
    set { defaults.set(newValue, forKey: Self.enabledKey) }
  }

  var relockAfter: TimeInterval {
    get {
      defaults.object(forKey: Self.relockAfterKey) == nil
        ? Self.defaultRelockAfter : defaults.double(forKey: Self.relockAfterKey)
    }
    set { defaults.set(max(0, newValue), forKey: Self.relockAfterKey) }
  }
}

@MainActor
struct PrivacyLockSettingsController {
  let authentication: any DeviceOwnerAuthenticating
  let store: any PrivacyLockStoring

  func setEnabled(_ requested: Bool) async -> DeviceOwnerAuthenticationOutcome? {
    guard requested else {
      store.isEnabled = false
      return nil
    }
    guard authentication.availability == .available else {
      store.isEnabled = false
      return .failed
    }

    let outcome = await authentication.authenticate(
      reason: "Unlock your private Indulge profile, Focus journal, and history."
    )
    store.isEnabled = outcome == .authenticated
    return outcome
  }
}

enum PrivacyLifecyclePhase: Equatable, Sendable {
  case active
  case inactive
  case background
}

struct PrivacyLockLifecycle: Equatable, Sendable {
  private(set) var isLocked: Bool
  private(set) var isObscured: Bool
  private(set) var leftActiveAt: Date?

  init(enabledAtLaunch: Bool) {
    isLocked = enabledAtLaunch
    isObscured = enabledAtLaunch
  }

  mutating func privacyLockWasEnabledAfterAuthentication() {
    isLocked = false
    isObscured = false
    leftActiveAt = nil
  }

  mutating func privacyLockWasDisabled() {
    isLocked = false
    isObscured = false
    leftActiveAt = nil
  }

  mutating func authenticationCompleted(_ outcome: DeviceOwnerAuthenticationOutcome) {
    if outcome == .authenticated {
      isLocked = false
      isObscured = false
    }
  }

  mutating func transition(
    to phase: PrivacyLifecyclePhase,
    now: Date,
    enabled: Bool,
    relockAfter: TimeInterval
  ) {
    guard enabled else {
      privacyLockWasDisabled()
      return
    }

    switch phase {
    case .inactive, .background:
      isObscured = true
      if leftActiveAt == nil { leftActiveAt = now }
    case .active:
      guard let leftActiveAt else { return }
      if now.timeIntervalSince(leftActiveAt) >= max(0, relockAfter) {
        isLocked = true
      }
      isObscured = isLocked
      self.leftActiveAt = nil
    }
  }
}
