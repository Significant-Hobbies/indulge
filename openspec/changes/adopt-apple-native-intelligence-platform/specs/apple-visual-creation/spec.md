## Purpose

Offer an Apple-native generative visual keepsake without replacing Indulge's
authored character, room, or causal animation system.

## ADDED Requirements

### Requirement: Visual generation is an explicit optional creation moment
The system SHALL offer visual generation only after the person deliberately
chooses to create a future-life card and SHALL present the system-managed creation flow.

#### Scenario: Person chooses to create a card
- **WHEN** visual generation is supported and the person activates the creation action
- **THEN** the system presents the native image-creation interface with concepts grounded in the person's chosen life directions

#### Scenario: Person cancels creation
- **WHEN** the person cancels the system interface
- **THEN** Indulge returns to the originating screen without creating a placeholder or changing the authored room

### Requirement: Authored product visuals remain the reliable core
The system SHALL keep bundled character and scene assets as the source of truth
for onboarding and daily-state animations regardless of visual-generation availability.

#### Scenario: Visual generation is unavailable
- **WHEN** the device cannot provide native image generation
- **THEN** the complete onboarding and daily application remain visually coherent with authored assets and the unavailable creation action is not presented as functional

### Requirement: Generated images remain under the person's control
The system SHALL retain a generated card only after successful completion and
SHALL allow the person to replace or delete it.

#### Scenario: Creation succeeds
- **WHEN** the system creation flow returns a valid image
- **THEN** Indulge stores one personal card with its creation date and originating life-direction concepts

#### Scenario: Person deletes a card
- **WHEN** the person confirms deletion of a generated card
- **THEN** the system removes the retained asset and its metadata without affecting the authored scene
