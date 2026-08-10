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

Planning lives in
`openspec/changes/build-indulge-visual-proof/`. Operational work is tracked in
[GitHub issue #1](https://github.com/Significant-Hobbies/indulge/issues/1).
