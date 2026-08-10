## Purpose

Let people protect sensitive Indulge history with the Apple device's own owner
authentication while keeping account creation out of the core experience.

## ADDED Requirements

### Requirement: Privacy lock is opt-in and device-native
The system SHALL allow a person to enable a privacy lock that uses the device's
available owner-authentication mechanism and SHALL keep it disabled by default.

#### Scenario: Person enables privacy lock
- **WHEN** device-owner authentication is available and the person explicitly enables the lock
- **THEN** the system verifies the person with the native authentication interface before saving the setting

#### Scenario: Device authentication is unavailable
- **WHEN** the device cannot evaluate an owner-authentication policy
- **THEN** the system explains that the lock is unavailable and does not enable a state that could lock the person out

### Requirement: Protected history relocks predictably
The system SHALL require successful device-owner authentication before showing
protected profile, focus, and history content after a configured background transition.

#### Scenario: Protected app returns from background
- **WHEN** the configured relock interval has elapsed while the app was not active
- **THEN** private content remains obscured until native device-owner authentication succeeds

#### Scenario: Authentication is cancelled or fails
- **WHEN** the authentication sheet is cancelled or does not authenticate the device owner
- **THEN** the system keeps private content obscured and offers a non-destructive retry

### Requirement: Core use does not require an Indulge account
The system SHALL NOT require Sign in with Apple, a passkey, an email address, or
an application account to complete onboarding or use local-first features.

#### Scenario: First launch
- **WHEN** a person opens Indulge for the first time
- **THEN** onboarding begins without an account prompt and explains only permissions that provide immediate value

#### Scenario: Server-side identity becomes necessary later
- **WHEN** a future feature requires an application account or cross-platform relying party
- **THEN** that feature requires a separate reviewed change defining Sign in with Apple or passkey enrollment, server validation, recovery, and account deletion
