# focus-interruption-journal Specification

## Purpose
Defines a private, manual record of focused work, attention interruptions, recovery cost, and evidence-bounded patterns that remain useful without automatic monitoring or AI availability.
## Requirements
### Requirement: Focus is a primary product destination
The application SHALL provide Focus as a fourth native tab beside Life, Trade, and History.

#### Scenario: Open Focus
- **WHEN** a person selects the Focus tab
- **THEN** they can review today's thread and start or continue a focus session with one primary action

### Requirement: Focus sessions preserve their real timing
The Focus surface SHALL let a person start a session with an optional intention and end it explicitly. An unfinished session SHALL remain active after an application relaunch.

#### Scenario: Start and finish focused work
- **WHEN** a person starts a focus session and later ends it
- **THEN** the application records the actual start and end timestamps and includes the elapsed focused time in the matching local day

#### Scenario: Relaunch during a session
- **WHEN** the application relaunches while a session has no end timestamp
- **THEN** Focus restores that session as active instead of silently discarding or completing it

### Requirement: One action records an interruption immediately
While a focus session is active, the application SHALL let a person mark an interruption with one action that immediately records its start and begins measuring recovery time.

#### Scenario: Flow breaks
- **WHEN** a person activates the interruption action
- **THEN** the interruption timestamp is persisted before any classification is requested

### Requirement: Interruptions capture reason and return blockage
Every completed interruption SHALL store a source, a reason for the break, and the blockage that made returning difficult. The application MAY also store a private optional note.

#### Scenario: Classify the break
- **WHEN** an interruption begins
- **THEN** the person can select whether it was external, self-initiated drift, or environmental and select a bounded reason without losing the recorded start time

#### Scenario: Return to focus
- **WHEN** the person says they are back
- **THEN** the application captures the return blockage, records the return timestamp, and resumes the same focus session

### Requirement: Daily summaries use recorded evidence only
The Focus surface SHALL group records by the person's local calendar day and show focused duration, interruption count, source mix, and total recovery time without fabricated values.

#### Scenario: Review a completed day
- **WHEN** at least one session or interruption exists for a day
- **THEN** that day shows values derived from its persisted timestamps and classifications

#### Scenario: Review a day without events
- **WHEN** no focus event has been recorded today
- **THEN** Focus presents an instructive empty thread instead of zero-filled charts or synthetic history

### Requirement: Aggregate insights require enough observations
The application SHALL generalize repeated sources, reasons, blockages, and recovery cost only from persisted events and SHALL show a learning state until at least three completed interruptions exist.

#### Scenario: Insufficient evidence
- **WHEN** fewer than three completed interruptions exist
- **THEN** the application explains how many more observations are needed and makes no behavioral claim

#### Scenario: Repeated pattern emerges
- **WHEN** at least three completed interruptions exist
- **THEN** the application may identify the most frequent source, reason, or blockage and its observed average recovery time using non-judgmental language

### Requirement: Recording remains local-first and AI-optional
Manual focus and interruption recording MUST work offline without Apple Intelligence. Persisted records SHALL remain in the application container unless a later explicit sync capability is added.

#### Scenario: Apple Intelligence is unavailable
- **WHEN** the device is ineligible, Apple Intelligence is disabled, or its model is not ready
- **THEN** every recording, classification, daily summary, and aggregate insight remains available through manual bounded choices

#### Scenario: On-device tagging is available
- **WHEN** the person enters an optional note and the on-device language model is available
- **THEN** the application may suggest bounded reason and blockage tags while keeping the person's explicit choices authoritative

### Requirement: Ordinary app switching is not an interruption
The application SHALL NOT create interruption events from ordinary application switching or claim that a switch represents lost focus without explicit user reporting.

#### Scenario: Switch applications during legitimate work
- **WHEN** the person changes applications without activating the interruption action
- **THEN** no interruption is recorded or inferred
