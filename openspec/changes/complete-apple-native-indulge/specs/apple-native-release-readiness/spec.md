## Purpose

Defines the evidence required before Indulge can be called ready for Apple device testing or TestFlight distribution without conflating simulator success with release readiness.

## ADDED Requirements

### Requirement: Critical journeys are automated across supported runtimes
The project SHALL run unit tests and native UI journeys for onboarding, persistence, trade completion, history, privacy settings, and deletion on the oldest and newest installed supported iOS simulators.

#### Scenario: Release verification runs
- **WHEN** the verification command completes
- **THEN** it reports the exact test total, failures, skips, devices, runtimes, build result, and strict specification result

### Requirement: Release evidence distinguishes simulator and physical-device claims
The project SHALL label CloudKit synchronization, device-owner authentication, Apple intelligence, and system visual creation as device-verified only after exercising them on compatible signed hardware.

#### Scenario: Device-only capability was not exercised
- **WHEN** release evidence is produced without a successful compatible-device run
- **THEN** the capability remains explicitly unverified and cannot be used to claim complete release readiness

### Requirement: Distribution signing is checked before TestFlight claims
The release tooling SHALL reject a TestFlight-ready claim when the archive is development-signed, includes debugging entitlement, or lacks an App Store distribution method.

#### Scenario: Free-development archive is produced
- **WHEN** an archive contains a development identity or `get-task-allow` entitlement
- **THEN** tooling describes it as a device-testing archive and does not label or upload it as TestFlight-ready

#### Scenario: App Store archive is produced
- **WHEN** an archive has the expected bundle, version, distribution signing, privacy manifest, and Apple entitlements
- **THEN** tooling may mark it ready for a separately authorized upload without performing that upload automatically

### Requirement: Verification leaves inspectable evidence
The project SHALL retain human-inspectable screenshots or recordings for the primary iPhone and iPad journeys, normal and Reduce Motion scene states, and empty and populated History.

#### Scenario: Verification completes
- **WHEN** automated and manual checks pass
- **THEN** evidence paths and remaining device-only limitations are recorded in project documentation
