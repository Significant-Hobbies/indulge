import Foundation
import LocalAuthentication
import Testing

@testable import Indulge

@MainActor
struct PrivacyLockTests {
  @Test func nativePolicyIncludesTheDevicePasscodeFallback() {
    #expect(LocalDeviceOwnerAuthenticationService.policy == .deviceOwnerAuthentication)
  }

  @Test func enablingRequiresSuccessfulDeviceOwnerAuthentication() async {
    let store = MemoryPrivacyLockStore()
    let authenticated = StubDeviceOwnerAuthentication(
      availability: .available,
      outcome: .authenticated
    )

    let outcome = await PrivacyLockSettingsController(
      authentication: authenticated,
      store: store
    ).setEnabled(true)

    #expect(outcome == .authenticated)
    #expect(store.isEnabled)
    #expect(authenticated.requestCount == 1)
  }

  @Test func unavailableDeviceCannotEnableOrLockOutThePerson() async {
    let store = MemoryPrivacyLockStore()
    let unavailable = StubDeviceOwnerAuthentication(
      availability: .unavailable,
      outcome: .failed
    )

    let outcome = await PrivacyLockSettingsController(
      authentication: unavailable,
      store: store
    ).setEnabled(true)

    #expect(outcome == .failed)
    #expect(!store.isEnabled)
    #expect(unavailable.requestCount == 0)
  }

  @Test func cancellationAndFailureNeverPersistAnEnabledLock() async {
    for outcome in [DeviceOwnerAuthenticationOutcome.cancelled, .failed] {
      let store = MemoryPrivacyLockStore()
      let service = StubDeviceOwnerAuthentication(
        availability: .available,
        outcome: outcome
      )

      let result = await PrivacyLockSettingsController(
        authentication: service,
        store: store
      ).setEnabled(true)

      #expect(result == outcome)
      #expect(!store.isEnabled)
    }
  }

  @Test func enabledLaunchStartsObscuredAndOnlySuccessUnlocks() {
    var lifecycle = PrivacyLockLifecycle(enabledAtLaunch: true)

    lifecycle.authenticationCompleted(.cancelled)
    #expect(lifecycle.isLocked)
    #expect(lifecycle.isObscured)
    lifecycle.authenticationCompleted(.failed)
    #expect(lifecycle.isLocked)
    #expect(lifecycle.isObscured)
    lifecycle.authenticationCompleted(.authenticated)
    #expect(!lifecycle.isLocked)
    #expect(!lifecycle.isObscured)
  }

  @Test func relockTimingUsesTheFirstTransitionAwayFromActive() {
    let start = Date(timeIntervalSince1970: 1_000)
    var lifecycle = PrivacyLockLifecycle(enabledAtLaunch: false)
    lifecycle.privacyLockWasEnabledAfterAuthentication()

    lifecycle.transition(to: .inactive, now: start, enabled: true, relockAfter: 60)
    #expect(lifecycle.isObscured)
    #expect(!lifecycle.isLocked)
    lifecycle.transition(
      to: .background,
      now: start.addingTimeInterval(10),
      enabled: true,
      relockAfter: 60
    )
    lifecycle.transition(
      to: .active,
      now: start.addingTimeInterval(59),
      enabled: true,
      relockAfter: 60
    )
    #expect(!lifecycle.isLocked)
    #expect(!lifecycle.isObscured)

    lifecycle.transition(
      to: .background,
      now: start.addingTimeInterval(100),
      enabled: true,
      relockAfter: 60
    )
    lifecycle.transition(
      to: .active,
      now: start.addingTimeInterval(160),
      enabled: true,
      relockAfter: 60
    )
    #expect(lifecycle.isLocked)
    #expect(lifecycle.isObscured)
  }

  @Test func disablingClearsLockedAndPendingLifecycleState() {
    let start = Date(timeIntervalSince1970: 1_000)
    var lifecycle = PrivacyLockLifecycle(enabledAtLaunch: true)
    lifecycle.transition(to: .background, now: start, enabled: true, relockAfter: 0)

    lifecycle.transition(
      to: .active,
      now: start.addingTimeInterval(1),
      enabled: false,
      relockAfter: 0
    )

    #expect(!lifecycle.isLocked)
    #expect(!lifecycle.isObscured)
    #expect(lifecycle.leftActiveAt == nil)
  }
}

@MainActor
private final class MemoryPrivacyLockStore: PrivacyLockStoring {
  var isEnabled = false
  var relockAfter: TimeInterval = 0
}

@MainActor
private final class StubDeviceOwnerAuthentication: DeviceOwnerAuthenticating {
  let availability: DeviceOwnerAuthenticationAvailability
  let outcome: DeviceOwnerAuthenticationOutcome
  private(set) var requestCount = 0

  init(
    availability: DeviceOwnerAuthenticationAvailability,
    outcome: DeviceOwnerAuthenticationOutcome
  ) {
    self.availability = availability
    self.outcome = outcome
  }

  func authenticate(reason: String) async -> DeviceOwnerAuthenticationOutcome {
    requestCount += 1
    return outcome
  }
}
