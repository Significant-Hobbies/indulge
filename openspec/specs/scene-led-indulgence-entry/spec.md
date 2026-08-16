# scene-led-indulgence-entry Specification

## Purpose
Makes Indulge's authored life scene the immediate, memorable way to begin an
intentional trade without introducing a separate tracker or dashboard.
## Requirements
### Requirement: The Life scene begins an intentional trade
The application SHALL make the primary Life scene an accessible action that
opens the Trade surface for the person's selected indulgence.

#### Scenario: Person taps the room
- **WHEN** the person activates the Life scene
- **THEN** the application opens Trade with their selected indulgence, suggested reclaim duration, and preferred life direction ready for review

#### Scenario: Person uses assistive technology
- **WHEN** the Life scene receives accessibility focus
- **THEN** it is announced as an action to shape an intentional trade rather than as a decorative image

### Requirement: Scene entry remains visually causal
The application SHALL communicate scene interactivity within the authored room
without placing a dashboard card, metric, or floating screenshot over the art.

#### Scenario: Life scene is idle
- **WHEN** no gesture is in progress
- **THEN** the scene shows a concise in-world action cue while keeping the character, furniture, and primary indulgence unobscured

#### Scenario: Person presses the scene
- **WHEN** the scene is pressed and Reduce Motion is disabled
- **THEN** the room responds with one restrained depth or framing change before Trade opens

#### Scenario: Reduce Motion is enabled
- **WHEN** the person activates the scene with Reduce Motion enabled
- **THEN** Trade opens without spatial travel while preserving the same action and content

