# Indulge

**Enjoy on purpose.**

Indulge is a native iPhone experience for keeping the indulgence someone
chooses, trading the time they do not, and watching a fuller life assemble
around one persistent animated character.

The first milestone is a deterministic SwiftUI + RealityKit visual proof. It
establishes the original soft-form 3D world, the modular indulgence recipe
system, and the hero transformations before Screen Time integration.

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

## Public site

The static Astro site under `src/` is the product, privacy, support,
accessibility, terms, and TestFlight surface for
`https://indulge.significanthobbies.com`. It ships no client-side JavaScript
and deploys to the `indulge` Cloudflare Pages project only after current-main CI
passes.

```bash
pnpm install
pnpm check
pnpm build
pnpm dev
```

When a verified public TestFlight URL exists, set `PUBLIC_TESTFLIGHT_URL` only
in the build environment. Without it, the site deliberately shows the honest
invite-only beta state.
