## Purpose

Defines the observable behavior of the persistent modular 3D scene that turns a
person’s choices into a coherent character, activity cluster, and expanding
representation of life.

## ADDED Requirements

### Requirement: Scene state composes one persistent world
The visual proof SHALL derive the visible character, environment, activity
objects, hand props, and possible-life objects from one explicit scene state.
Changing that state SHALL update the existing world rather than replace it with
an unrelated screen or character.

#### Scenario: Replaying a saved visual-proof state
- **WHEN** the visual proof loads the same scene state twice
- **THEN** it presents the same character variant, objects, spatial zones, and
  settled composition both times

### Requirement: Watching selection assembles an activity cluster
Selecting watching TV SHALL cause a sofa, television, and practical lamp to
enter the scene and SHALL place the persistent character into a relaxed watching
pose after the furniture has made visual contact with the stage.

#### Scenario: User selects watching TV
- **WHEN** the user selects the watching-TV indulgence in the fake-data flow
- **THEN** the stage, sofa, television, lamp, and watching pose appear as one
  causally ordered transformation

### Requirement: Companion preferences modify the existing pose
The scene SHALL support adding a compatible detachable hand, lap, table, floor,
or ambient prop without replacing the activity cluster or creating a second
character.

#### Scenario: User adds a warm drink preference
- **WHEN** the watching scene is settled and the user selects the warm-drink
  companion preference
- **THEN** a mug arrives at the character’s available hand and the hand closes
  into a compatible holding pose

#### Scenario: User declares wine with watching TV
- **WHEN** the watching scene is settled and the user explicitly selects wine as
  part of their own context
- **THEN** a wine glass arrives at the compatible hand socket without changing
  the sofa, television, character identity, or non-moralizing scene tone

### Requirement: Possible life expands rather than erases
The Now ↔ Possible state SHALL retain the selected indulgence objects while
adding space and at least three meaningful replacement-family objects.

#### Scenario: User scrubs toward Possible
- **WHEN** the user moves the preview from Now toward Possible
- **THEN** the sofa and television remain visible while the scene gains spatial
  breadth and objects representing reading, movement, and creating or restoring

### Requirement: Visual progress never decays
Inactive, skipped, or intentionally extended indulgence states MUST NOT remove,
damage, darken, or shamefully re-pose previously earned life objects.

#### Scenario: User chooses more intentional time
- **WHEN** the fake flow records an intentional continuation
- **THEN** the current world remains intact and the scene presents the
  continuation as a neutral choice rather than a loss state
