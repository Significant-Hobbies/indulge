# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Users

People who repeatedly spend longer than intended scrolling, streaming, gaming,
or browsing and want a kinder way to reclaim some of that time without giving
up the enjoyment they deliberately choose.

The product is used privately on an iPhone, often at the edge of an automatic
digital habit or when reflecting on how time was spent.

## Product Purpose

Indulge helps a person notice one automatic digital escape, decide how much of
it they genuinely want to keep, trade a modest amount of unchosen time for a
satisfying alternative, and watch those alternatives become part of a living
representation of their life.

Success is not abstinence. It is more meaningful replacement sessions, fewer
episodes that last longer than intended, and eventual graduation from the
intervention when a new rhythm feels natural.

## Positioning

Indulge makes reclaimed time emotionally visible as an expanding life scene.
It never treats intentional indulgence as failure and is designed to be
outgrown rather than retained through guilt, streaks, or competitive pressure.

## Operating Context

- One active trade at a time, involving user-selected apps and websites.
- A small set of three context-aware replacements based on need, time, energy,
  and place.
- One persistent life scene across onboarding, daily use, history, and
  graduation.
- First run builds a private local profile through optional identity, activities
  that repeatedly take longer than intended, time, context, need, intentionality, desired life direction, and
  preferred pace. It reflects the pattern back without diagnosis or a score.
- Apple Screen Time authorization is requested only after the user has seen the
  value of the future-life preview; denial preserves a manual mode.
- Significant Hobbies is a potential source for the replacement-activity
  library and a possible post-graduation next chapter, not the host app.
- Focus is a first-class mobile surface for manually reporting attention
  interruptions and recovery periods through the same Indulge pattern model.
  It records where attention escaped, what made returning difficult, and daily
  recovery cost without productivity scoring, automatic app-switch judgment,
  or a separate companion product.

## Capabilities and Constraints

- Native SwiftUI iPhone app with local-first persistence and no account.
- Name and gender are optional onboarding context. Gender supports
  self-description and prefer-not-to-say; neither answer is used to infer
  behavior or prescribe a different intervention.
- One active trade; intentional extensions are allowed and are never failure.
- V1 visual coverage targets a curated library of roughly 20–30 indulgence
  scenes assembled from reusable poses, furniture clusters, and companion props.
- Life, Focus, Trade, and History are the primary V1 surfaces; graduation
  removes Trade while preserving Life, Focus, and History.
- Focus recording is manual and local-first: starting a session, interrupting,
  classifying the reason, recording the return blockage, and returning must all
  work offline without Apple Intelligence. On supported devices, Apple's
  on-device model may suggest bounded tags from an optional note, but the user
  remains authoritative.
- Screen Time integrations use FamilyControls, DeviceActivity,
  ManagedSettings, and ManagedSettingsUI with manual fallback.
- Core functionality works offline. Raw Screen Time history, selected app
  names, and selection tokens are not uploaded.
- The app must support Dynamic Type, VoiceOver, Dark Mode, increased contrast,
  and Reduce Motion.
- User-declared alcohol or smoking context may be mirrored neutrally as a scene
  companion prop. The app does not recommend substance pairings, treat substance
  dependence, score consumption, or present clinical guidance.
- V1 excludes clinical addiction support, gambling intervention, Android,
  social features, competition, AI coaching, complex analytics, large avatar
  creation, and multiple simultaneous trades.

## Brand Commitments

- Name: Indulge.
- Working tagline: “Enjoy on purpose.”
- Product promise: keep the indulgence you choose, trade the time you lose, and
  see a fuller life take shape.
- Voice is intimate, adult, calm, non-moralizing, and free of shame, shock
  statistics, punishment, or forced optimism.
- The primary experience is an emotionally legible animated life scene, not a
  dashboard or a habit tracker decorated with illustrations.

## Evidence on Hand

- The owner-provided V1 visual and animation brief is at
  `/Users/sarthak/Downloads/indulge_ios_visual_prd.md`.
- Significant Hobbies issue #65 records the product boundary and research
  relationship but is reference-only, not Indulge’s operational work queue.
- No production character art, Rive rig, user research, testimonials,
  benchmarks, analytics, or App Store assets exist yet and must not be
  fabricated as evidence.

## Product Principles

1. Trade and limit; never ban by default.
2. Express progress as more life, never as punishment or scene decay.
3. Make the replacement easier to choose when the user is tired.
4. Let animation prove emotional causality rather than merely decorate state.
5. Preserve dignity and intentional pleasure all the way through graduation.

## Accessibility & Inclusion

The same stylized adult character persists through the journey and supports
inclusive silhouettes, skin tones, hair, clothing, and accessibility variants.
Growth is shown through action, environment, and presence—not body change,
beauty reward, or a “before” character portrayed as pathetic. The full product
must remain understandable and satisfying with Reduce Motion enabled.
