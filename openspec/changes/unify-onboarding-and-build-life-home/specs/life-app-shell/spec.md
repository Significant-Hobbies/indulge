## Purpose

Defines the first useful local app experience after onboarding: a living scene, one clear time trade, and an honest record of completed activity.

## ADDED Requirements

### Requirement: Three primary product surfaces
The app shell SHALL provide Life, Trade, and History as the primary destinations using familiar native tab navigation.

#### Scenario: Open app after onboarding
- **WHEN** onboarding completes
- **THEN** Life is selected and Trade and History are reachable with one tab action

### Requirement: Life begins with the living scene
The Life surface SHALL make the user's selected character and indulgence scene the dominant content and SHALL summarize the first pattern without presenting a generic dashboard, score, streak, or fabricated analytics.

#### Scenario: First Life visit
- **WHEN** a newly onboarded user opens Life
- **THEN** the chosen scene, primary indulgence, ordinary duration when provided, and desired life direction are visible with one clear action to create the first trade

### Requirement: Trade establishes one intentional exchange
The Trade surface SHALL let the user define a first local trade using the selected indulgence, a modest reclaim target, and one desired life direction while preserving intentional use as allowed. It SHALL represent the exchange with the actual indulgence image on the origin side and distinct authored destination imagery on the reclaimed-time side.

#### Scenario: Review first trade
- **WHEN** a user opens Trade before a trade exists
- **THEN** the selected indulgence, current self-reported time, proposed reclaimed time, available desired directions, and a direct create action are shown without website blocking or Screen Time authorization

#### Scenario: Choose what reclaimed time becomes
- **WHEN** the user selects a desired direction such as sleep, creativity, relationships, movement, calm, or focus
- **THEN** the destination side changes to that direction's authored scene while the origin continues to show the selected indulgence

#### Scenario: Create first trade
- **WHEN** a user confirms the proposed trade
- **THEN** the interface shows the indulgence, reclaim target, and destination as active locally and Life reflects the complete exchange

### Requirement: Destination imagery is complete
Every supported life direction SHALL resolve to distinct authored bitmap artwork in the established soft 3D visual language. The production Trade interface SHALL NOT substitute a generic symbol tile when a direction changes.

#### Scenario: Review any life direction
- **WHEN** a supported life direction appears as a destination
- **THEN** its own image is visible and differs from the origin indulgence and every other destination

### Requirement: Distraction reporting remains honest
The first local product loop SHALL treat the primary indulgence, common moments, starting trigger, and intentionality as self-reported context. It SHALL NOT infer that ordinary application switching is a distraction or claim automatic enforcement.

#### Scenario: User changes applications during ordinary work
- **WHEN** no explicit interruption or indulgence event has been recorded
- **THEN** Indulge does not create a distraction event or judge the switch

### Requirement: History never fabricates progress
The History surface SHALL show an instructive first-use state until the user completes a real trade event.

#### Scenario: No completed trade exists
- **WHEN** a newly onboarded user opens History
- **THEN** the interface explains what will appear after the first trade and provides a route to Trade without synthetic charts or invented metrics

### Requirement: App shell continues the onboarding design system
Life, Trade, and History SHALL use the same Powder Sky, Cherry, navy, rounded material, scene assets, typography, and concise language as the coherent onboarding journey, with Operate-mode restraint.

#### Scenario: Transition from reflection to Life
- **WHEN** the app animates from the final onboarding reflection into Life
- **THEN** the character, room, palette, and control vocabulary remain visually continuous while navigation changes to the standard app shell

### Requirement: Local launch presets support review
The application SHALL expose deterministic development launch states for Life, Trade, active Trade, and empty History.

#### Scenario: Launch a review state
- **WHEN** the app is started with a supported review argument
- **THEN** it opens directly to that app surface with stable illustrative profile data and no network dependency
