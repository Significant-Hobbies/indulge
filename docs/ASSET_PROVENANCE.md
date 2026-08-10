# Asset provenance

## Direction references

- `artifacts/design/references/rounded-3d-sofa-quality-benchmark.png` was
  provided by the owner as a quality benchmark. It is internal-only and must not
  ship or be traced.
- `artifacts/design/directions/soft-form-stage-{a,b,c}.png` were generated for
  Indulge with OpenAI's built-in image-generation tool. They are composition and
  craft references, not production runtime assets.
- `artifacts/design/directions/indulge-onboarding-cinematic-target.png` and
  `indulge-onboarding-smoke-target.png` were generated specifically for Indulge
  with OpenAI's built-in image-generation tool on 2026-08-08. They establish the
  approved adult editorial character, room, furniture, lighting, and contact
  quality for the onboarding proof.

## Runtime assets

The reusable 20–30-scene systems proof uses original procedural RealityKit
geometry. The customer-facing onboarding proof uses original generated
cinematic plates derived from the targets above and cropped into:

- `Indulge/Resources/OnboardingStanding.png`
  is the superseded first proof plate and is retained as source history but
  excluded from the application bundle.
- `Indulge/Resources/OnboardingStandingV2.png` was generated with OpenAI's
  built-in image-generation tool on 2026-08-08 as the distinct neutral room:
  the same character stands before any indulgence furniture or prop appears.
- `Indulge/Resources/OnboardingWatching.png`
- `Indulge/Resources/OnboardingWine.png`
- `Indulge/Resources/OnboardingSmoke.png`

SwiftUI supplies the actual state transitions, camera breathing, crossfades,
copy, controls, accessibility, and Reduce Motion behavior. No third-party or
reference-site imagery ships in the app. Record any later imported source asset
here with author, source URL, license, attribution requirement, modifications,
and final in-repository path before use.
