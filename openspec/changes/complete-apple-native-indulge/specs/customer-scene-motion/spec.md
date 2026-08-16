## Purpose

Makes the authored room behave like a living consequence of the person’s choices throughout the real customer journey while remaining understandable with motion reduced.

## ADDED Requirements

### Requirement: Scene motion appears in the customer journey
The application SHALL use the production authored character and room on onboarding, Life, Trade, and completion surfaces with motion that responds to the selected indulgence and trade state.

#### Scenario: Indulgence changes during onboarding
- **WHEN** a person selects an indulgence whose scene differs from the current scene
- **THEN** the room changes through a causal arrival sequence rather than an unrelated static replacement

#### Scenario: Trade begins from Life
- **WHEN** a person activates the Life room and begins a trade
- **THEN** the room gives one restrained spatial response and the Trade surface preserves the same person, indulgence, furniture, and primary prop

#### Scenario: Trade is completed
- **WHEN** a person records a completed trade
- **THEN** the selected life direction appears as a new bounded pocket in the same visual world without removing or shaming the indulgence

### Requirement: Specific choices remain visually recognizable
The application SHALL expose only indulgence choices that have selector artwork, a compatible scene role, an arrival treatment, and a settled reduced-motion state.

#### Scenario: Catalog coverage is validated
- **WHEN** the production catalog is tested
- **THEN** every visible indulgence resolves to authored selector artwork and one deterministic scene recipe with no generic photo placeholder

### Requirement: Motion remains accessible and efficient
The application SHALL preserve the same state changes and meaning when Reduce Motion is enabled and SHALL pause nonessential ambient motion when the scene is not visible.

#### Scenario: Reduce Motion is enabled
- **WHEN** a scene state changes
- **THEN** the application uses ordered crossfades and in-place changes without parallax, overshoot, or large spatial travel

#### Scenario: Scene leaves the visible hierarchy
- **WHEN** the application moves to another surface or the background
- **THEN** repeating ambient animation stops until the scene becomes visible again
