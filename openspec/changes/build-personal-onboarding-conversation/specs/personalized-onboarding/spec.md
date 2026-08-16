## Purpose

Defines a private, adaptive first-run conversation that learns a person’s
identity, indulgence pattern, and desired life direction before Indulge asks
for permissions or suggests any intervention.

## ADDED Requirements

### Requirement: Onboarding unfolds as a personal conversation
The application SHALL present one clear question per beat. Its first-value
journey SHALL include preferred name, gender presentation, time-sapping
activities, primary indulgence, approximate time spent, the purpose the
indulgence serves, desired life changes, and a personalized reflection. It SHALL
ask gender before showing feminine or masculine character artwork. It SHALL
offer optional deeper personalization containing common time of day, how the
indulgence begins, how chosen the time still feels, and preferred pace of change
after that first reflection.

#### Scenario: Person completes the core conversation
- **WHEN** a person advances through onboarding
- **THEN** each beat asks one focused question and the first reflection is reachable without completing deeper personalization

#### Scenario: Person chooses deeper personalization
- **WHEN** the first reflection is visible and the person asks to make it more personal
- **THEN** the application presents the optional detail questions and returns to an enriched reflection

#### Scenario: Onboarding opens
- **WHEN** a person launches onboarding for the first time
- **THEN** the first interactive beat asks “What should we call you?” with its input and primary action visible without scrolling
- **AND** it does not display a brand masthead, decorative progress bar, chapter label, scene caption, or explanatory paragraph
- **AND** it does not display a separate Skip action because the primary action accepts an empty optional name

#### Scenario: Person returns to an earlier answer
- **WHEN** a person uses Back and changes a prior answer
- **THEN** subsequent personalized copy and the final reflection use the updated answer

### Requirement: Identity questions are inclusive and private
The application SHALL allow a preferred name to be empty, SHALL offer
inclusive gender choices including self-description and “Prefer not to say,”
and SHALL use gender only for character presentation rather than eligibility or
judgment. It SHALL require an explicit inclusive choice before proceeding so it
never infers gender from behavior.

#### Scenario: Person declines identity information
- **WHEN** the person leaves their name empty or selects “Prefer not to say” for gender
- **THEN** onboarding remains complete and uses neutral language without reducing functionality

#### Scenario: Person supplies a self-described identity
- **WHEN** the person selects self-description
- **THEN** the application accepts a short custom identity value and uses neutral visual treatment

#### Scenario: Person explicitly identifies as a woman or man
- **WHEN** the person selects Woman or Man
- **THEN** equivalent feminine or masculine character artwork may be used in subsequent scenes
- **AND** scene capability, quality, and available indulgence choices remain identical
- **AND** behavior is never used to infer character presentation

#### Scenario: Character presentation carries through scene changes
- **WHEN** the scene changes from standing to an indulgence pose
- **THEN** the same character identity, clothing, camera, lighting, and fixed
  room architecture remain visible
- **AND** only the pose, furniture, and props caused by the selection change

### Requirement: Indulgence discovery precedes change planning
The application SHALL learn which activities repeatedly take more time than a
person wants, how long they occupy, when they happen, what triggers them, and
what need they meet before asking what the person wants to change. It SHALL NOT
frame general enjoyment, good habits, restriction, or abstinence as the opening
task.

#### Scenario: Person reaches activity discovery
- **WHEN** the activity-selection beat appears
- **THEN** it asks what takes more of the person's time than they want
- **AND** it does not ask the person to catalog everything they enjoy

#### Scenario: Person identifies television as an indulgence
- **WHEN** the person selects Watching TV on the activity-selection beat
- **THEN** the sofa and television scene appears immediately and before any desired-change question

#### Scenario: Person selects another activity
- **WHEN** the visible activity catalog is presented
- **THEN** each visible item has authored 3D selector artwork, a compatible scene role, an arrival treatment, and a Reduce Motion settled state
- **AND** unfinished items remain hidden instead of using an SF Symbol or generic medallion as indulgence artwork

#### Scenario: Person selects scrolling
- **WHEN** the person selects Scrolling on the activity-selection beat
- **THEN** a phone arrives and settles directly into the standing character's hand
- **AND** the application does not show the generic floating activity medallion

#### Scenario: Person combines compatible indulgences
- **WHEN** the person selects an activity that can share the current scene
- **THEN** the new object occupies a deterministic compatible character or room socket without replacing prior compatible selections
- **AND** the selector and scene show the same selected membership

#### Scenario: Person browses the indulgence catalog
- **WHEN** activity discovery is visible
- **THEN** the application offers the detailed launch catalog of roughly 20–30 specific indulgences rather than only broad category buckets

#### Scenario: Person reaches the purpose question
- **WHEN** the person has identified a primary indulgence and its ordinary duration
- **THEN** the application asks an action-specific question about what the person is looking for when that action begins
- **AND** the answer choices describe possible purposes rather than whether the behavior feels chosen or automatic
- **AND** the beat does not add a chapter message or explanatory paragraph around the question
- **AND** the beat does not offer Skip or repeat the scene state as a caption

### Requirement: Questions adapt to prior answers
The application SHALL reuse supplied answers in later prompts, SHALL select
relevant follow-up language based on the primary indulgence and time estimate,
and SHALL make visible how answers are shaping the experience.

#### Scenario: Preferred name is available
- **WHEN** a person supplies a preferred name
- **THEN** at least one later prompt and the final reflection address the person by that name

#### Scenario: Time estimate is available
- **WHEN** the person chooses an approximate daily duration
- **THEN** the reflection describes that duration in humane language without shock statistics or moral judgment

### Requirement: Sensitive answers remain local and deliberate
The application SHALL state that onboarding answers stay on device for this
milestone, SHALL never preselect a sensitive identity or behavioural answer,
and SHALL not require an account or network connection.

#### Scenario: Onboarding begins offline
- **WHEN** the device has no network connection
- **THEN** all questions, personalization, navigation, and the final reflection remain available

#### Scenario: Sensitive question appears
- **WHEN** the person reaches gender, time-use, or intentionality questions
- **THEN** no substantive answer is preselected and skipping remains available where appropriate

### Requirement: The final reflection feels earned and nonjudgmental
The application SHALL summarize the person’s primary indulgence, approximate
time, underlying need, and desired life direction while explicitly protecting
the pleasure they intentionally choose.

#### Scenario: Person reaches the reflection
- **WHEN** required questions are complete
- **THEN** the application presents a personalized narrative rather than a score, streak, warning, diagnosis, or generic success screen

### Requirement: The flow is natively accessible and resilient
The application SHALL provide progress semantics, 44-point minimum targets,
Dynamic Type reflow, keyboard avoidance, VoiceOver labels and selected states,
Reduce Motion alternatives, and layouts for phone and iPad widths.

The application SHALL use Dynamic Type-backed system typography, a warm
project-specific semantic palette, current native iOS material and sensory
feedback APIs where supported, and equivalent accessible fallbacks on the
minimum supported operating system.

The application SHALL keep the persistent scene and current question in one
bounded viewport, with the primary action anchored independently from any
scrolling answer list.

#### Scenario: Accessibility text size is enabled
- **WHEN** the person uses an accessibility Dynamic Type size
- **THEN** the current question and its primary action remain reachable by scrolling without overlap

#### Scenario: A question or answer list is long
- **WHEN** the current onboarding beat needs more vertical reading or answer space
- **THEN** the cinematic stage compacts into a persistent scene rail instead of disappearing
- **AND** the same current image remains visible while the answer list scrolls independently

#### Scenario: Reduce Motion is enabled
- **WHEN** the system Reduce Motion preference is active
- **THEN** large travel and ambient zoom stop while answer causality remains visible through short fades and in-place changes

#### Scenario: Standard motion is enabled
- **WHEN** a generated scene plate is visible
- **THEN** bounded parallax, breathing-scale motion, practical-light drift, and causal spring crossfades give the scene life without moving the controls

#### Scenario: Keyboard is visible
- **WHEN** the person enters their name or self-described identity
- **THEN** the cinematic stage collapses to a compact safe-area scene rail that keeps the current image visible
- **AND** the text field and continue action remain reachable without being compressed behind the keyboard
- **AND** the keyboard can be dismissed interactively

#### Scenario: The app runs on different supported iOS generations
- **WHEN** the onboarding runs on iOS 18 or a newer system with additional native material capabilities
- **THEN** the hierarchy, contrast, controls, and interaction semantics remain equivalent while the newer system may provide richer native material rendering
