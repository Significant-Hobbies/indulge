# Indulge build 2 verification

Verified on 16 August 2026 from the current working tree.

## Automated matrix

| Target | Result |
| --- | --- |
| iPhone, iOS 27.0 | 68 unit tests in 7 suites and 3 UI journeys passed; 2 hardware-only UI checks skipped |
| iPhone, iOS 26.4 | 68 unit tests in 7 suites and 3 UI journeys passed; 2 hardware-only UI checks skipped |
| iPad Pro 11-inch, iPadOS 27.0 | 68 unit tests in 7 suites and 3 UI journeys passed; 2 hardware-only UI checks skipped |
| Current-source build | `./scripts/build.sh` passed |
| Current-source focused unit run | 68 tests in 7 suites passed |
| Current-source iOS 27 UI run | All 3 customer journeys passed together; 2 physical-only checks skipped |
| Physical iPhone 16 Pro, iOS 27.0 | 66 tests in 7 suites passed after correcting the card-file defect found only on hardware |
| Provider-neutral static site | type/content check, production build, and production dependency audit passed; 0 known vulnerabilities |

The UI journeys cover completing a trade into populated History, relaunch
persistence, active-trade replacement, settings deletion, and accessibility
reachability. Test runs use a launch-only isolated data reset so one journey
cannot contaminate another.

The owner accepted this complete simulator matrix as the current verification
gate on 16 August 2026. Physical-device installation, completed system
authentication, and two-device private CloudKit behavior remain separately
deferred and are not represented by simulator results.

## Visual evidence

- `iphone-onboarding-standard.png`
- `iphone-onboarding-dark.png` (onboarding intentionally retains its authored daylight palette)
- `iphone-onboarding-accessibility-xl.png`
- `iphone-life-increased-contrast.png`
- `iphone-trade-active-standard.png`
- `iphone-trade-active-reduce-motion.png`
- `iphone-history-empty-standard.png`
- `iphone-history-completed-standard.png`
- `iphone-history-completed-final.png`
- `iphone-history-completed-dark.png`
- `ipad-life-standard-final.png`
- `ipad-history-completed-standard.png`
- `physical-iphone-launch.png`
- `physical-iphone-relaunch.png`
- `latest-simulator-app-settled.png` (fresh current-source iOS 27 first-run launch)

The captures were inspected for Dynamic Island bleed, safe-area collisions,
choice reachability, active-trade continuity, truthful History content, Dark
Mode, increased contrast, Accessibility XL, and Reduce Motion.

## Native and release boundary

- The release archive links Apple system frameworks only and contains no
  embedded third-party framework, web view, remote model client, or Cloudflare
  runtime.
- All 19 changed or newly added Swift files pass strict `swift-format` lint,
  and the full working-tree diff passes whitespace validation. A recursive
  lint of untouched legacy sources is not used as a release claim because the
  repository has no formatter configuration and those files use an older
  indentation convention.
- The privacy manifest parses successfully.
- `build/Indulge-Build2-Physical-Verified.xcarchive` is the current corrected
  archive. It is signed by personal team
  `8F7LXHTJZR` with Apple Development,
  development push/iCloud entitlements, and `get-task-allow`; the archive
  inspector correctly classifies it as `development-device`.
- The guarded TestFlight script refuses that archive before export or upload.
  No upload was attempted.
- The previous exact archive was installed and launched on the paired iPhone 16
  Pro running iOS 27.0 with Developer Mode enabled. A terminate/relaunch cycle
  reopened the same completed profile, proving local persistence on physical
  hardware; the two physical screenshots above are the evidence.
- The first full physical unit run exposed three future-life-card failures that
  did not reproduce in Simulator. The owned-file validation was made lexical
  and deterministic, and the repeated physical run then passed all 66 tests.
- A physical LocalAuthentication availability test passed. The physical test
  process reports `supportsImagePlayground == false`, so the deterministic
  authored-card fallback is the exercised capability state for this run.
- An explicitly attended authentication test reached Apple’s real system
  prompt but was not completed, so successful Face ID/passcode authentication
  remains unverified. The prompt was interrupted without enabling Privacy Lock.
- After that interrupted system prompt, the CoreDevice install service timed
  out while installing the corrected archive. The archive is built and signed,
  but installation of this newest artifact is not claimed yet.
- Two-device private CloudKit behavior remains explicitly unverified because no
  second compatible physical device is available. No simulator result is used
  as a substitute for authentication or sync.

## Product truth

The customer app is Life → Trade → History. Focus records remain only as legacy
schema types for migration safety. Foundation Models, Screen Time monitoring,
accounts, subscriptions, analytics, and automatic app-switch detection are not
customer features in build 2.
