# Consumer onboarding research applied to Indulge

Accessed 2026-08-09.

## Search frame

The surface is Indulge's native iPhone and iPad first run. Its primary outcome
is not account creation or feature education; it is helping someone feel
accurately, privately, and nonjudgmentally understood through one indulgence
pattern. The product is an experience-led consumer app. The existing warm room,
character, local-only privacy boundary, name-first opening, indulgence-first
scope, accessible native controls, and permission-after-value rule remain
fixed. The desired qualities are intimate, animated, quick, adaptive, and
adult; the anti-qualities are quiz, assessment, marketing carousel, shame, and
mandatory exhaustive intake.

## Primary guide

**Appnovation — _First Impressions Matter: Apps Onboarding Guide_**

- Source: <https://www.appnovation.com/sites/default/files/2022-02/Apps%20Onboarding%20Guide-Appnovation%20Resource.pdf>
- Local reference: `appnovation-apps-onboarding-guide.pdf`
- Surface inspected: the complete 18-page guide, especially pages 12–15 on
  progressive disclosure, essential onboarding, instant reward, and the final
  do/don't summary.
- Transferable lesson: lower interaction cost by revealing value immediately;
  ask only essential setup questions; disclose the rest at the moment it is
  useful; show the personalized result instead of promising it.
- Avoid: the guide's enterprise examples, dated UI examples, visual styling,
  and any copied wording or assets.
- Constraint fit: Indulge can make the selected room transform immediately and
  can produce a first personal reflection before requesting optional profile
  detail or Screen Time access.

The PDF is copyrighted by Appnovation and marked “all rights reserved.” It is
kept here only as a local research reference. No text, imagery, layout, or
brand asset from it is reused in the product.

## Supporting references

### Apple Human Interface Guidelines — Onboarding

- Source: <https://developer.apple.com/design/human-interface-guidelines/onboarding>
- Surface inspected: onboarding best practices and additional requests.
- Transferable lesson: onboarding should be fast, fun, optional, and
  interactive; postpone nonessential setup; request permissions when their
  benefit is contextual and clear.
- Avoid: a tutorial or splash sequence that explains the system rather than
  letting the person use Indulge.
- Constraint fit: the room itself can teach the product by changing in response
  to an answer, while deeper questions and permissions can wait.

### RevenueCat — Activation metrics that predict retention

- Source: <https://www.revenuecat.com/blog/growth/activation-metrics>
- Surface inspected: first value, core value, time to first value, and
  onboarding-completion caveats.
- Transferable lesson: define and measure a real first-value moment rather than
  treating completion as success. A personalized insight is a plausible first
  value signal; completion alone is not.
- Avoid: importing subscription or paywall tactics into this local-first proof,
  or optimizing step count without checking whether the result feels valuable.
- Constraint fit: Indulge's first-value event can be “viewed a personalized
  reflection after selecting an indulgence,” followed later by repeated use as
  the core-value test.

## Anti-reference

The mandatory twelve-screen lifestyle intake is the anti-reference. Even with
excellent art and one-question-per-screen pacing, it withholds value while
collecting identity, context, trigger, need, and change preferences. Likewise,
a three-slide benefits carousel would describe Indulge without letting the
person experience it.

## Direction principles

1. Make the room respond on the indulgence-selection screen, within the first
   two meaningful interactions.
2. Keep the first-value journey to name, indulgence, duration, intentionality,
   desired direction, and a personalized reflection.
3. Offer gender, common moment, trigger, underlying need, and preferred pace as
   a voluntary deeper-personalization journey after the first reflection.
4. Explain privacy and duration once, in context; do not lead with a feature
   tour or permission request.
5. Evaluate first-value reach and later return behavior, not onboarding
   completion in isolation.

## Applied product decision

The SwiftUI flow uses a seven-beat first-value journey. Selecting an activity
immediately selects it as the current primary preview and transforms the room;
the next beat lets the person confirm or change that primary indulgence. The
reflection offers an optional “Make this more personal” route containing five
deeper questions, then returns to an enriched reflection. No third-party UI,
copy, art, or production dependency is introduced.

Owner direction is already delegated by the request to find a strong consumer
onboarding guide and apply it; no reference-style selection remains.
