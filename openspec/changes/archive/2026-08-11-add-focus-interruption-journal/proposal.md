## Why

Indulge currently understands where time escapes but cannot record the focus period that was broken, why it broke, or how expensive returning was. A first-class Focus tab turns the product from a static reflection into a useful local record of interruption frequency, cause, recovery cost, and repeated patterns.

## What Changes

- Add Focus as a fourth native tab beside Life, Trade, and History.
- Let a person start and end a named focus session, mark an interruption immediately, and mark the moment they return.
- Capture a bounded reason and return blockage for each interruption, with optional private notes.
- Persist focus sessions and interruptions locally with SwiftData so daily history survives relaunches.
- Show per-day focused time, interruption count, recovery time, and source mix using only recorded events.
- Generalize repeated reasons, blockages, and recovery patterns only after enough observations exist; show an honest learning state before then.
- Add an availability-gated Foundation Models boundary that can suggest bounded tags from optional notes on supported Apple Intelligence devices while preserving manual tagging and a deterministic fallback.
- Keep V0 manual: no automatic app-switch judgment, Screen Time inference, blocking, productivity scoring, or cloud sync.

## Capabilities

### New Capabilities

- `focus-interruption-journal`: Manual focus-session and interruption capture, local persistence, daily summaries, and evidence-bounded aggregate insights.

### Modified Capabilities

None. The repository has no archived main specifications yet.

## Impact

- Affects the SwiftUI app root, tab shell, launch presets, and adds Focus views, domain models, storage, summary logic, and tests.
- Adds SwiftData and an optional Foundation Models integration using Apple system frameworks only; no third-party or network dependency is introduced.
- Persists private interruption data in the app's local container. CloudKit entitlements and cross-device synchronization remain out of scope.
- Requires iOS 18-compatible manual behavior; on-device language-model tagging is compiled and used only where the Foundation Models framework and model are available.
