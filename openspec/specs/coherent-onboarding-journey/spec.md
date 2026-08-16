# coherent-onboarding-journey Specification

## Purpose
Defines a visually continuous first-run conversation that preserves the user's scene and turns their answers into an immediate product handoff.
## Requirements
### Requirement: One visual world across onboarding
The onboarding journey SHALL use the Powder Sky, Cherry, navy typography, light material tray, and generated room-stage vocabulary established by the activity-selection beat for every question.

#### Scenario: Move between different question types
- **WHEN** a user advances from a visual choice to text entry, a single choice, a multi-choice question, or the reflection
- **THEN** the room stage, surface colors, control states, typography hierarchy, and primary action remain recognizably part of one continuous experience

### Requirement: One complete main journey
The onboarding journey SHALL include name, gender, time-draining activities, primary indulgence, duration, common moments, starting trigger, underlying need, intentionality, desired life direction, preferred pace, and reflection in one ordered conversation. It SHALL NOT hide any of those questions behind a secondary personalization action.

#### Scenario: Reach the first reflection
- **WHEN** a user continues through onboarding
- **THEN** every personalization question appears before the reflection and the reflection has no "make this more personal" branch

### Requirement: Multiple common moments
The onboarding journey SHALL let a user select one or more times when the indulgence tends to pull them in and SHALL preserve all selected moments in the final profile and reflection.

#### Scenario: Select several pull moments
- **WHEN** a user selects morning, breaks, and late night
- **THEN** all three choices remain visibly selected, the user can continue, and the reflection describes the combined timing in natural language

#### Scenario: Remove one selected moment
- **WHEN** a user taps an already selected moment
- **THEN** only that moment is removed and the remaining selected moments stay intact

### Requirement: Scene continuity survives the conversation
The onboarding journey SHALL keep the selected character presentation and current indulgence scene visible through later questions, using a compact crop only when content or the keyboard requires more room.

#### Scenario: Continue after selecting an indulgence
- **WHEN** a user selects an indulgence and advances through time, purpose, and life-direction questions
- **THEN** the same character and corresponding activity environment remain visible rather than reverting to an unrelated standing scene or generic background

### Requirement: Dense questions remain usable
The onboarding journey MUST keep the current question, answer controls, and primary action discoverable on supported iPhones, Dynamic Type sizes, and keyboard states without relying on an invisible whole-screen scroll.

#### Scenario: Long answer list on phone
- **WHEN** answer options exceed the available tray height
- **THEN** only the answer region scrolls, a native scroll indicator is available, and the primary action remains anchored above the safe area

#### Scenario: Keyboard appears
- **WHEN** a text field receives focus
- **THEN** the stage becomes a compact character rail and the field plus primary action remain visible

### Requirement: Completion enters the product
The final first-run action SHALL transfer the completed local profile into the app shell and SHALL NOT end only with animation, haptics, or a developer-only screen.

#### Scenario: Finish first reflection
- **WHEN** a user activates the final onboarding action
- **THEN** the app opens the Life surface with the selected character scene and personalized indulgence context intact

### Requirement: Accessibility preserves meaning
The coherent journey MUST support VoiceOver, Dynamic Type, increased contrast, Reduce Motion, and differentiation without color.

#### Scenario: Reduce Motion is active
- **WHEN** the system Reduce Motion preference is enabled
- **THEN** scene changes use short crossfades or in-place state changes while preserving the causal relationship between answer and scene

