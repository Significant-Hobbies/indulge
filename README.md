# Indulge

**Enjoy on purpose.**

Indulge is a native iPhone and iPad experience for keeping the indulgence someone
chooses, trading the time they do not, and watching a fuller life assemble
around one persistent animated character and room.

The current build is a complete local-first Life → Trade → History loop. A
12-beat onboarding identifies where time is being pulled, one deliberate trade
can be created and completed, and real outcomes persist into History. The
customer-facing scene uses bundled original soft-3D plates with native,
Reduce-Motion-aware presentation; the repository also retains the RealityKit
scene engine used to prove the modular 24-indulgence system.

## Local development

Requirements:

- Xcode 16 or newer
- XcodeGen 2.46 or newer
- iOS 18.0 or newer (`RealityView` is the minimum-version constraint)

```bash
./scripts/build.sh
INDULGE_TEST_DESTINATION='platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' ./scripts/test.sh
```

The deployment target is iOS 18.0. Local runtime verification uses the oldest
matching runtime installed on the development Mac (currently iOS 26.4) plus the
newest installed runtime. The app does not call RealityKit APIs newer than the
iOS 18 availability boundary.

Planning lives under `openspec/changes/`. The Apple-native intelligence, visual
creation, privacy-lock, and private-sync preparation is tracked in
[GitHub issue #3](https://github.com/Significant-Hobbies/indulge/issues/3).
Physical visual-proof work remains tracked in
[GitHub issue #1](https://github.com/Significant-Hobbies/indulge/issues/1).

The native app has no third-party runtime, web view, analytics SDK, remote-model
call, or Cloudflare dependency. SwiftData is authoritative. Properly entitled
signed builds may attempt the configured private CloudKit container and fall
back to local-only storage; cross-device sync is not claimed until it is tested
on two signed devices. Image Playground is the only generative Apple surface in
the current product, and the authored fallback remains complete without it.

## Public site

The static Astro site under `src/` is the product, privacy, support,
accessibility, terms, and TestFlight surface for
`https://indulge.significanthobbies.com`. It ships no client-side JavaScript,
contains no provider-specific deployment configuration, and can be built as
portable static files.

```bash
pnpm install
pnpm check
pnpm build
pnpm dev
```

Fleet-facing quality scripts live in the root `package.json`: `format:check`,
`lint`, `typecheck`, `test`, `test:coverage`, `knip`, and the `quality:*`
wrappers. Landing types stay on `astro check`. Native tests and coverage stay
on `./scripts/test.sh` / XCTest.

When a verified public TestFlight URL exists, set `PUBLIC_TESTFLIGHT_URL` only
in the build environment. Without it, the site deliberately shows the honest
invite-only beta state.
