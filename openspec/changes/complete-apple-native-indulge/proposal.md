## Why

Indulge’s onboarding and native visual language are strong enough to demonstrate the idea, but the daily product stops before a person can actually complete and retain a trade. The release must close that loop, expose its native scene motion in the customer journey, and remove Cloudflare-specific infrastructure so the product runtime and private data path are Apple-native.

## What Changes

- Persist one active trade and completed trade history in SwiftData with stable identifiers, local-first writes, and private CloudKit-compatible fields.
- Turn Trade into a complete daily loop: create, begin, finish, optionally record what happened, and see truthful history derived only from completed trades.
- Reuse the authored scene and existing RealityKit/SwiftUI motion vocabulary in the normal Life and Trade journey, with deterministic Reduce Motion behavior.
- Keep all essential behavior offline and deterministic; Apple Foundation Models may improve bounded wording only when available and never become a dependency.
- Remove Cloudflare configuration, deployment code, provider-origin claims, and runtime assumptions from this repository. Keep the native application on Apple frameworks and keep any static trust content provider-neutral.
- Harden deletion, relaunch restoration, empty/error states, accessibility, iPhone/iPad adaptation, and release signing checks.
- Prepare an Apple-distribution archive without uploading or promoting CloudKit production state.

## Capabilities

### New Capabilities

- `daily-trade-loop`: Persistent creation, activation, completion, and truthful history for one active indulgence trade.
- `customer-scene-motion`: Customer-facing causal scene motion shared by onboarding, Life, Trade, and completion, including Reduce Motion alternatives.
- `apple-only-product-boundary`: An Apple-framework application runtime and Apple-private data path with no Cloudflare-specific infrastructure or dependency.
- `apple-native-release-readiness`: Repeatable build, test, archive, privacy, signing, and device-verification evidence without unauthorized upload or production promotion.

### Modified Capabilities

- `focus-interruption-journal`: Legacy Focus records remain migration-safe but no longer count as active product functionality or generated-intelligence input.

## Impact

- Affects the SwiftData schema and migration plan, app container, Life/Trade/History UI, scene presentation, settings deletion, tests, documentation, and release scripts.
- Uses SwiftUI, SwiftData, CloudKit, RealityKit, LocalAuthentication, and availability-gated Apple system intelligence/creation frameworks only; no production package dependency is added.
- Removes Cloudflare-specific project files and deployment scripts. No deploy, upload, schema promotion, commit, or push is performed by this change.
