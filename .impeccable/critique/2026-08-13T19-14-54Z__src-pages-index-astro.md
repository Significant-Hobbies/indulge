---
target: "Reduce oversized mobile screenshots on the landing page (#14)"
total_score: 28
max_score: 32
na_heuristics: 7,9
p0_count: 0
p1_count: 0
timestamp: 2026-08-13T19-14-54Z
slug: src-pages-index-astro
---
Method: dual-agent (A: indulge_design_review · B: indulge_detector_review)

## Design Health Score

| # | Heuristic | Score | Key issue |
|---|---|---:|---|
| 1 | Visibility of system status | 3 | Honest beta-status fallback; no active workflow states apply. |
| 2 | Match system / real world | 4 | Humane language matches the user's real tension. |
| 3 | User control and freedom | 3 | Clear anchors and reversible FAQ accordions; mobile primary navigation is intentionally reduced. |
| 4 | Consistency and standards | 4 | Typography, color, CTA, phone framing, and chapter rhythm remain coherent. |
| 5 | Error prevention | 4 | Verified beta URL guard prevents a false enrollment action. |
| 6 | Recognition rather than recall | 4 | Text-labelled actions and adjacent app proof minimize memory load. |
| 7 | Flexibility and efficiency | n/a | Static marketing surface with no repeat workflow. |
| 8 | Aesthetic and minimalist design | 3 | Strong hierarchy; 390px product proof is compact enough that screen detail becomes secondary. |
| 9 | Error recovery | n/a | No form or user-generated workflow exists. |
| 10 | Help and documentation | 3 | FAQ, privacy, support, accessibility, and beta-status routes are present. |
| **Total** | | **28/32** | **Good** |

## Design Specificity Verdict

The page is authored and recognizably Indulge. Its powder-sky room, cherry route, character imagery, non-moralizing copy, and life-assembling metaphor form a coherent visual world. The revised mobile layout fixes the oversized screenshot failure without deleting any of the four product chapters.

The deterministic detector returned zero findings in `src/pages/index.astro`. Browser measurements found zero horizontal overflow at 390, 768, and 1440 pixels; loaded product screenshots retained their 660×1434 ratio. No console errors or warnings appeared. Mutable overlay injection was unavailable, so native screenshots and read-only DOM measurements were used as visual evidence.

## Overall Impression

The fix restores mobile pacing: the 390px page falls from 15,698px to 8,704px while preserving every product chapter. The largest remaining opportunity is to make the compact phone proof inspectable without returning to full-height screenshots.

## What's Working

- Explicit `width: 100%; height: auto` preserves screenshot proportions.
- Alternating compact chapters retain the narrative path and product-specific visual language.
- The voice and trust material remain unusually honest and aligned with the product.

## Priority Issues

- **P2 — Mobile app proof is miniature:** At 390px the phone proof is about 109–123px wide. The silhouette and feature association survive, but in-screen details are not independently legible. A future focused crop or accessible enlargement could improve proof without restoring the old page length.
- **P2 — The core causal experience is asserted rather than demonstrated:** Static screenshots cannot show a choice causing the room to assemble. A restrained reduced-motion-safe before/after could make the differentiator more tangible.
- **P2 — Conversion momentum falls after the chapter peak:** Fit, Privacy, FAQ, and Founder create a long trust corridor before the closing action.
- **P3 — TestFlight assumes Apple beta familiarity:** Plain-language companion microcopy could reduce first-timer hesitation.

No P0 or P1 remains in the mobile-screenshot sizing change.

## Persona Red Flags

- **Jordan:** TestFlight may not communicate the next step, and the compact screenshots cannot answer detailed product questions alone.
- **Riley:** Honest beta and privacy fallbacks withstand scrutiny; static imagery cannot verify the promised causal room assembly.
- **Casey:** The shorter page, lazy loading, and above-fold action work well; compact copy-and-proof rows require more concentrated reading.

## Minor Observations

- Cognitive load is low: zero of eight checklist failures and no primary decision point exceeds four choices.
- The 768px layout scales especially well, and all tested widths have zero horizontal overflow.
- A separate pre-existing P2 exists on lazy privacy/closing brand imagery that lacks the same global `height: auto` safeguard; it is outside issue #14's screenshot scope.

## Questions to Consider

- Could a tap-to-enlarge treatment preserve compact pacing while restoring inspectable product proof?
- Would one quiet beta action immediately after the four chapters improve conversion without cheapening the trust sequence?
- What is the lightest way to demonstrate choice → room change without adding decorative motion?
