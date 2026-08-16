## Why

Indulge’s first-run experience must earn unusually high trust before asking a
person to reflect on private, potentially shame-laden behaviour. The current
visual proof demonstrates one indulgence scene, but it does not yet learn who
the person is, what the indulgence does for them, how much time it occupies, or
what they genuinely want their life to feel like.

## What Changes

- Replace the short proof onboarding with an adaptive, one-question-at-a-time
  conversation split into a fast first-value journey and voluntary deeper
  personalization.
- Keep the optional name and inclusive gender choices private, and ask gender
  before resolving the abstract character into feminine or masculine artwork.
- Let the indulgence selection transform the scene immediately, then use the
  essential answers in a first reflection before asking for additional detail.
- Keep common moment, trigger, intentionality, and change pace available after
  the first reflection rather than making all of them prerequisites for value.
- Use progressive disclosure, comfortable pacing, reversible navigation, keyboard
  handling, haptics, and a first-class Reduce Motion path.
- Preserve the indulgence-first boundary: the flow learns the present pattern
  before mentioning replacements, restrictions, or good habits.
- Refine the established visual language with a warmer native palette, SF Pro
  Rounded display moments, SF Pro Text for readable conversation, and current
  iOS materials, haptics, and motion with backward-compatible fallbacks.
- Add deterministic launch presets and tests for the major onboarding states.

## Capabilities

### New Capabilities

- `personalized-onboarding`: A private, adaptive onboarding conversation that
  builds an initial local indulgence profile and reflects it back with dignity.

### Modified Capabilities

None.

## Impact

- Replaces the customer-facing onboarding entry view and introduces local
  onboarding state and question models.
- Reuses the existing SwiftUI app shell and original scene plates; no new
  production dependency or remote service is required.
- Adds simulator evidence, accessibility coverage, and focused unit tests.
- Does not yet persist answers across launches, request Screen Time access, or
  implement replacement recommendations.
