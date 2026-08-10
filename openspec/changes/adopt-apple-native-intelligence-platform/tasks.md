## 1. Versioned Local Data Foundation

- [ ] 1.1 Add a versioned SwiftData schema and migration plan covering existing Focus records.
- [ ] 1.2 Remove CloudKit-incompatible unique constraints, retain stable UUIDs and indexes, and add deterministic event deduplication tests.
- [ ] 1.3 Persist the completed onboarding profile and restore it into the daily application after relaunch.
- [ ] 1.4 Add generated-reflection and future-life-card metadata records with explicit deletion behavior.
- [ ] 1.5 Run local-store migration, relaunch, duplicate-import, and startup-repair tests with CloudKit disabled.

## 2. Shared Apple Intelligence Experience

- [ ] 2.1 Add one injectable capability snapshot and intelligence protocol that expose availability, work, cancellation, and failure states.
- [ ] 2.2 Add a typed evidence-packet builder from persisted profile, indulgence, and Focus aggregates with a stable evidence revision.
- [ ] 2.3 Fold interruption tag suggestion into the shared service while preserving the authored manual fallback and explicit-choice precedence.
- [ ] 2.4 Add a guided Foundation Models reflection adapter and authored fallback for headline, grounded observation, and optional question.
- [ ] 2.5 Cache generated reflections by evidence revision and invalidate them when authoritative evidence changes.
- [ ] 2.6 Present the grounded reflection in Life and Focus without exposing prompt mechanics or blocking the deterministic summary.
- [ ] 2.7 Add availability, prompt-regression, schema, cancellation, failure, grounding, and insufficient-evidence tests.

## 3. Apple Device Privacy Access

- [ ] 3.1 Add an injectable device-owner authentication service with available, unavailable, authenticated, cancelled, and failed outcomes.
- [ ] 3.2 Add an opt-in privacy-lock setting that authenticates successfully before enabling and stores no biometric material.
- [ ] 3.3 Obscure protected content across scene-phase transitions and implement configurable relock timing with retry.
- [ ] 3.4 Add lifecycle, unavailable-device, cancellation, passcode-fallback, and lockout-prevention tests.

## 4. Apple Visual Creation

- [ ] 4.1 Add an availability-gated Image Playground system-sheet adapter using bounded concepts from persisted life directions.
- [ ] 4.2 Add a preserve-mode Life entry point for creating a future-life card without extending onboarding or replacing the authored room.
- [ ] 4.3 Copy successful output into application-owned storage and implement replace and confirmed-delete actions for image and metadata.
- [ ] 4.4 Verify cancellation, unavailable-device, successful-retention, replacement, deletion, Dynamic Type, VoiceOver, and Reduce Motion states.

## 5. Private CloudKit Synchronization

- [ ] 5.1 Audit the complete versioned schema against CloudKit constraints and keep previews and tests on explicit local configurations.
- [ ] 5.2 Add explicit development entitlements and XcodeGen configuration for iCloud CloudKit plus remote-notification background delivery.
- [ ] 5.3 Provision or select the private development container with the Apple Developer team and record its exact identifier without exposing credentials.
- [ ] 5.4 Select the explicit private CloudKit configuration only in properly entitled signed builds and preserve local-first behavior otherwise.
- [ ] 5.5 Verify offline writes, delayed sync, stable-ID deduplication, competing active-session repair, and all-data deletion across two signed devices.
- [ ] 5.6 Promote the tested CloudKit schema only as a separately authorized release step; do not infer production promotion from development success.

## 6. Product and Quality Gates

- [ ] 6.1 Update PRODUCT.md and DESIGN.md with the grounded-intelligence, private-sync, visual-keepsake, privacy-lock, and no-account-wall boundaries.
- [ ] 6.2 Run the project test script on the minimum supported simulator and build with the current iOS 27 SDK.
- [ ] 6.3 Verify native-model and Image Playground supported states on a compatible physical device plus deterministic unsupported simulator states.
- [ ] 6.4 Run strict OpenSpec validation, Swift formatting, diff checks, and the preserve-mode Impeccable critique and audit with zero unresolved P0/P1.
- [ ] 6.5 Record external provisioning blockers and require explicit owner approval before CloudKit production promotion, commit, push, or release.
