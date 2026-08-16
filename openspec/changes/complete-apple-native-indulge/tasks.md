## 1. Persistent Trade Domain

- [x] 1.1 Add a CloudKit-compatible V2 SwiftData trade record with stable identity, lifecycle timestamps, outcome, indulgence, target, and destination fields.
- [x] 1.2 Add the lightweight V1-to-V2 migration and prove existing profile, card, and legacy Focus stores reopen without data loss.
- [x] 1.3 Implement a main-actor trade repository that enforces one active trade and supports create, begin, complete, replace, history, and all-data deletion.
- [x] 1.4 Add unit tests for persistence, relaunch, active-record repair, each completion outcome, ordering, offline-local configuration, and deletion.

## 2. Complete the Daily Product

- [x] 2.1 Replace `@State` trade ownership with SwiftData-backed active and completed queries shared by Life, Trade, and History.
- [x] 2.2 Add deliberate start, finish, intentional-extension, not-today, and active-trade replacement interactions with non-judgmental native confirmation states.
- [x] 2.3 Build populated History from completed records with locale-aware dates and truthful deterministic totals, preserving the honest empty state.
- [x] 2.4 Include active and completed trades in settings deletion and verify the app returns to first run cleanly.
- [x] 2.5 Harden writes against double submission and recover from persistence errors without discarding the visible trade.

## 3. Customer-Facing Scene Motion

- [x] 3.1 Extract a shared authored-scene presenter with bounded breathing, parallax, practical-light drift, causal crossfades, and offscreen cancellation.
- [x] 3.2 Use the presenter in onboarding, Life, Trade, and completion while preserving character, room, indulgence, and gender-selected continuity.
- [x] 3.3 Add a completion pocket for the selected life direction without replacing or morally degrading the indulgence scene.
- [x] 3.4 Implement equivalent crossfade-only Reduce Motion behavior and tests for motion-plan selection and semantic summaries.
- [x] 3.5 Verify every one of the 24 visible indulgences has authored selector art, deterministic scene role, arrival treatment, and settled state with no generic placeholder.

## 4. Apple-Only Boundary

- [x] 4.1 Remove Wrangler, Cloudflare configuration, Cloudflare deployment scripts, provider origins, and Cloudflare-specific product claims while retaining provider-neutral static trust content.
- [x] 4.2 Regenerate the JavaScript lockfile and prove the static content build no longer includes a Cloudflare package or command.
- [x] 4.3 Audit the native binary and source for web views, third-party runtime frameworks, remote model calls, and Cloudflare endpoints.
- [x] 4.4 Reconcile Apple-native documentation so SwiftData, optional private CloudKit, LocalAuthentication, Image Playground, and deterministic fallbacks match the implementation.

## 5. Release and Device Verification

- [x] 5.1 Extend native UI automation through trade completion, populated History, relaunch persistence, replacement confirmation, settings deletion, and accessibility reachability.
- [x] 5.2 Run the complete unit and UI suite on the oldest and newest installed supported iPhone runtimes plus representative iPad layouts.
- [x] 5.3 Capture standard, Dark Mode, increased-contrast, accessibility-size, and Reduce Motion evidence for onboarding, active Trade, completed History, and empty states.
- [ ] 5.4 Install and launch a personal-team signed development build on available compatible hardware; exercise local persistence, privacy authentication, and supported Apple capability states without claiming untested sync.
- [x] 5.5 Add archive inspection that distinguishes development-device archives from App Store/TestFlight-ready distribution archives and never uploads automatically.
- [x] 5.6 Run builds, strict OpenSpec validation, privacy-manifest inspection, linked-framework audit, formatting/diff checks, Impeccable critique/polish/native audit, and record evidence with zero unresolved P0/P1.

## 6. Product Truth and Closeout

- [x] 6.1 Update PRODUCT.md, DESIGN.md, PROJECT_STATUS.md, README, and release notes to describe only verified shipped behavior and remaining physical-device boundaries.
- [x] 6.2 Reconcile the completed Apple-native intelligence and visual-proof OpenSpec tasks against actual evidence without checking unsupported-device or external-promotion work.
- [x] 6.3 Validate and archive completed OpenSpec changes, update main specs, and leave the latest verified native build open for owner keep/close/wrong-lane feedback.
