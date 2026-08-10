## Why

The first activity-selection screen establishes a bright, cinematic Powder Sky and Cherry world, but the rest of onboarding returns to an older dark form system and completion leads nowhere. The product needs one continuous visual and behavioral journey that earns trust during onboarding and immediately delivers the promised living-life experience inside the app.

## What Changes

- Extend the first page's light material, typography, controls, room framing, and causal scene transitions across every onboarding question and reflection.
- Fold identity, timing, trigger, intentionality, and pace into one complete main onboarding journey instead of placing them behind a secondary personalization fork.
- Let people select every time of day when the indulgence tends to pull them in, and carry those moments into their reflection.
- Turn the first Trade into a visible exchange: preserve the selected distraction, choose what a small reclaimed pocket becomes, and show distinct authored imagery on both sides.
- Keep existing answers, accessibility behavior, and the no-skip decision while removing the visual and structural split between core and "advanced" questions.
- Turn onboarding completion into a real handoff to an authenticated-style local app shell rather than a dead-end success haptic.
- Add the first inside-app surfaces: Life as the opening living scene, Trade as the next action for reclaiming time, and History as an honest first-use state.
- Reuse the selected indulgence and character presentation so the person and room remain continuous across onboarding and daily use.
- Keep the implementation local-first and illustrative: no Screen Time permission, blocking, account, cloud sync, or fabricated behavioral history in this change.

## Capabilities

### New Capabilities

- `coherent-onboarding-journey`: Every onboarding beat uses one persistent visual system and hands completed profile state into the product.
- `life-app-shell`: A native three-surface application shell presents the living scene, the first trade action, and honest history states after onboarding.

### Modified Capabilities

None. The repository has no archived main specifications yet.

## Impact

- Affects the SwiftUI app root, onboarding presentation, onboarding completion behavior, theme components, Life/Trade/History views, and destination artwork.
- Adds local in-memory session state and deterministic launch presets for visual verification; no production dependency or persistence migration is introduced.
- Reuses existing generated scene plates and accessibility settings.
