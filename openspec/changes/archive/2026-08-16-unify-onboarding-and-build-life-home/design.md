## Context

The current onboarding contains two visual systems in one view: the activity beat uses Powder Sky, Cherry, navy, white material, and generated room plates, while every other step uses an older dark aubergine and teal presentation. `ContentView` routes either to onboarding or a developer `IndulgeReviewView`; completing the reflection does not change application state. Existing generated scene plates, `OnboardingProfile`, theme tokens, accessibility behaviors, and deterministic presets are reusable.

## Goals / Non-Goals

**Goals:**

- Treat the existing light activity-selection page as the visual authority and extend it through onboarding and daily use.
- Preserve one profile and scene state from the first answer through the Life surface.
- Establish a small but real app loop: understand the pattern, create one trade, see that trade in Life, and keep History honest until use exists.
- Keep new product state local and dependency-free.

**Non-Goals:**

- Screen Time authorization, shields, app selection, notifications, accounts, cloud sync, durable analytics, or a complete production persistence layer.
- Replacing generated plates with a real-time 3D rig.
- Building good-habit recommendations, AI coaching, streaks, scoring, or fabricated history.

## Decisions

### Extend the light visual world instead of inventing another direction

This is a preserve-lane change. Powder Sky provides the room field and quiet secondary controls, Cherry carries only selected state and primary action, navy carries text and active navigation, and white material owns readable content. Every onboarding step adopts these roles. The dark teal/aubergine form presentation is removed from this journey rather than blended into the new world.

Alternative considered: keep dark screens for reflective questions. Rejected because it makes a single conversation feel like multiple products and visually disconnects answers from the animated scene.

### Use one adaptive stage-and-tray composition

All onboarding steps keep the existing stage above a rounded light tray. Short questions may use a taller stage; dense questions and focused text fields use a compact crop. Only the prompt content scrolls, while the primary action remains pinned. Selection rows, grids, text fields, reflection details, and back/progress controls share the same light component vocabulary.

Alternative considered: create unique layouts for each question. Rejected because the repeated shift would recreate the inconsistency and make keyboard and Dynamic Type behavior harder to reason about.

### Use one ordered onboarding sequence

`PersonalOnboardingStep` owns a single main journey containing all twelve beats. The earlier first-value/deeper-personalization split and reflection branch are removed. This adds several taps, but avoids asking the person to understand which questions are "advanced" and ensures the first product state has the context it needs.

Alternative considered: keep the short path and preselect the advanced answers later. Rejected because it hides meaningful intent, timing, and agency behind defaults the person did not choose.

### Store common moments as an ordered set of choices

The profile stores common moments as a set, while display and reflection always order them by the authored `CommonMoment.allCases` sequence. The existing grid becomes multi-select, shows a selected count, and toggles each value independently. Reflection copy uses natural one-, two-, and three-plus-item grammar rather than exposing raw enum labels.

Alternative considered: add a free-form "other time" field. Deferred because the four broad dayparts cover the current insight model and the user asked for a simple multi-select change.

### Handoff profile state through a root session container

`ContentView` owns a small session phase and an `OnboardingProfile`. `IndulgeOnboardingView` receives a completion closure and passes its final profile to the root. Development launch arguments can initialize the root directly in a selected app tab. This is intentionally in-memory; a persistence boundary can replace it later without changing the visible contract.

Alternative considered: write onboarding state to `UserDefaults` now. Rejected because the storage model is not yet designed and persistence is not needed to prove the inside-app loop.

### Build the shell with native tab navigation and a shared scene header

The app uses a three-tab `TabView` for Life, Trade, and History. Life leads with the full selected generated scene and a compact pattern summary. Trade is a focused builder with a conservative default reclaim target derived from self-reported duration. History uses a composed empty state rather than fake data. Shared surfaces and buttons live in the theme layer so the app remains visually coherent.

Alternative considered: a custom floating navigation bar. Rejected because standard native tabs are more legible, accessible, and appropriate for an Operate surface; brand expression belongs in the scenes and precise components.

### Keep trade state illustrative but interactive

The first trade can be created during the session. The app derives readable current and reclaim labels from the onboarding time bucket and updates Life to show an active trade. It does not pretend to enforce limits or record recovered time.

### Make the exchange visual and destination-aware

`ActiveTrade` stores one `LifeDirection` alongside the indulgence and reclaim target. Trade defaults to the first authored direction the person selected during onboarding, but lets them switch among all selected directions before confirmation. A single exchange composition keeps the indulgence artwork fixed on the left and crossfades the destination artwork on the right, so the interaction reads as "less automatic television, more creativity" rather than as a numeric limit form.

Each `LifeDirection` owns a dedicated soft-3D bitmap vignette. These scenes focus on the destination's physical evidence—bed and moonlight, shared table, making desk, walking path, quiet window, focused desk, or journal—rather than generating another inconsistent character identity. This keeps the existing gender-matched room plate dominant while making every destination visually specific.

Alternative considered: reuse SF Symbols inside colored cards. Rejected because the product's core promise is a living visual transformation and generic symbols make each destination feel interchangeable.

## Risks / Trade-offs

- [In-memory state resets when the process restarts] → Label this as the first interactive shell and keep the state boundary isolated for later persistence.
- [Large scene plates can pressure memory] → Load only the current scene image and avoid simultaneously rendering hidden tab scenes.
- [A shared layout can become monotonous] → Vary stage height and information density while keeping palette and component grammar stable.
- [Light surfaces may lose contrast over pale art] → Place controls in opaque or material white surfaces and keep navy/cherry contrast roles fixed.
- [Illustrative trade defaults may be mistaken for enforcement] → Use explicit language such as “a first trade” and “nothing is blocked yet.”

## Migration Plan

1. Add the root session and app-shell types behind deterministic launch presets.
2. Restyle onboarding controls and surfaces without changing answer semantics.
3. Connect the final reflection action to the root completion closure.
4. Validate onboarding presets, app-shell presets, accessibility layouts, and the existing scene tests.
5. The previous developer review surface remains available behind `--review` for animation inspection.
