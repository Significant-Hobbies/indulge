## Why

Indulge already uses SwiftUI, SwiftData, and a bounded Foundation Models tagger,
but its intelligence, sync, visual creation, and privacy boundaries are still
isolated implementation details. The product should feel deeply native to the
Apple ecosystem while remaining private, offline-capable, and fully usable on
devices where Apple Intelligence is disabled or unavailable.

## What Changes

- Establish one capability-gated Apple intelligence layer for structured tag
  suggestions, evidence-grounded daily reflections, and cross-pattern narration.
- Keep deterministic calculations authoritative; generated text may explain
  stored facts but may not invent observations, diagnoses, or advice.
- Persist the onboarding profile and generated reflections in SwiftData, then
  prepare a CloudKit-private sync configuration for the person's Apple devices.
- Add an explicit Image Playground moment for creating an optional future-life
  card while preserving the authored character and room as the core visual world.
- Add an optional Face ID or device-authentication privacy lock for sensitive
  local history.
- Do not add a sign-in wall. CloudKit uses the person's iCloud account; Sign in
  with Apple or passkeys remain deferred until Indulge has a genuine server-side
  account or cross-platform identity requirement.
- Keep on-device Foundation Models as the default. Private Cloud Compute and any
  transmission of raw notes remain outside this change.

## Capabilities

### New Capabilities

- `apple-intelligence-experience`: Availability-gated, structured Apple
  Foundation Models features with grounded inputs and deterministic fallbacks.
- `apple-private-sync`: SwiftData persistence and CloudKit-private synchronization
  for profile, focus, and generated product state.
- `apple-visual-creation`: An optional system Image Playground flow whose output
  can be retained as a personal future-life card.
- `apple-privacy-access`: Optional system device-owner authentication protecting
  private Indulge history without creating an application account.

### Modified Capabilities

None. The repository has no archived main specifications yet.

## Impact

- Affects the application model container, SwiftData schema, onboarding profile
  handoff, Focus insight services, Life or reflection presentation, settings,
  launch routing, tests, and XcodeGen signing/capability configuration.
- Uses Apple system frameworks only: Foundation Models, SwiftData, CloudKit,
  Image Playground, and Local Authentication. No production package dependency
  is added.
- CloudKit requires an Apple Developer team, iCloud container, remote-notification
  background capability, and a compatible schema. Provisioning that external
  container is a separate explicit setup step and must not be claimed from local
  simulator success.
- Tracked by GitHub issue #3.
