## Purpose

Defines how motion communicates causality, emotion, and physical weight when a
choice recomposes the character and modular world.

## ADDED Requirements

### Requirement: Major transformations communicate cause and effect
Every major transformation SHALL visibly connect the user’s choice to the
resulting space, object, or character action using an authored sequence rather
than simultaneous generic entrances.

#### Scenario: Watching scene arrives
- **WHEN** the user confirms watching TV
- **THEN** space clears first, the primary furniture arrives second, the
  character settles third, and the smallest companion detail arrives last

### Requirement: Motion is interruptible
A new user-selected scene state SHALL take control from an in-flight
transformation without snapping through stale end states or leaving duplicate
objects visible.

#### Scenario: User changes selection mid-animation
- **WHEN** a user selects a different indulgence before the current scene has
  settled
- **THEN** the visible entities continue from their current transforms toward
  the new scene state and only the new state’s objects remain active

### Requirement: Hero and utility motion use different timing
Hero scene transformations SHALL last approximately 1–2 seconds, while control
feedback and utility transitions SHALL respond immediately using native-feeling
timing.

#### Scenario: User confirms an activity
- **WHEN** a choice is confirmed
- **THEN** its control responds immediately and the consequential scene
  transformation completes within two seconds

### Requirement: Haptics mark meaningful physical contact
The app SHALL provide a restrained haptic at the moment a primary trade is
confirmed or a major object completes its settle, and SHALL NOT emit haptics for
ambient loops.

#### Scenario: Sofa settles
- **WHEN** the sofa reaches its final transform after the watching selection
- **THEN** the app emits one subtle settle haptic and no repeated ambient haptic

### Requirement: Ambient motion remains quiet
The settled scene SHALL animate no more than three ambient elements at once and
SHALL keep the primary character silhouette and actionable controls legible.

#### Scenario: Watching scene is idle
- **WHEN** the scene has remained settled for at least one second
- **THEN** only a bounded set such as breathing, lamp variation, and a subtle
  screen bounce continue moving

### Requirement: The proof includes the six hero beats
The visual proof SHALL expose replayable present-life reveal, trade transform,
Now ↔ Possible scrub, replacement completion, weekly morph, and graduation
beats using the same scene world.

#### Scenario: Reviewer enters demo mode
- **WHEN** the reviewer opens the visual-proof sequence
- **THEN** each of the six hero beats can be triggered and replayed without
  requiring Screen Time authorization or persisted user data
