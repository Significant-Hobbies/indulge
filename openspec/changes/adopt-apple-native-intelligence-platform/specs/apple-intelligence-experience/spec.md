## Purpose

Make Indulge intelligently interpret and explain a person's own evidence while
keeping every essential action available without generative model support.

## ADDED Requirements

### Requirement: Core behavior never depends on model availability
The system SHALL preserve onboarding, focus recording, history, and deterministic
summaries when generative intelligence is unsupported, disabled, not ready,
blocked, or fails during generation.

#### Scenario: Model is unavailable
- **WHEN** a person uses Indulge on a device where the native model is unavailable
- **THEN** every recording and summary action completes with authored fallback behavior and without a dead control

#### Scenario: Generation fails after an action begins
- **WHEN** a native generation request throws, is cancelled, or is blocked
- **THEN** the system preserves the person's stored data and returns to deterministic content without presenting fabricated output

### Requirement: Generated insights remain grounded in stored evidence
The system SHALL generate only from bounded, structured facts calculated from
the person's stored events and profile, and SHALL NOT invent events, durations,
causes, diagnoses, or behavioral advice.

#### Scenario: Daily reflection is generated
- **WHEN** sufficient completed evidence exists for a daily or cross-pattern reflection
- **THEN** every factual claim in the generated reflection corresponds to a supplied aggregate and the output follows a bounded structured schema

#### Scenario: Evidence is insufficient
- **WHEN** the deterministic evidence floor has not been reached
- **THEN** the system shows an authored learning state instead of asking the model to infer a pattern

### Requirement: Explicit choices remain authoritative
The system SHALL treat generated tags and wording as suggestions and SHALL keep
the person's explicit source, reason, blockage, and profile choices authoritative.

#### Scenario: Suggested tag differs from the person's choice
- **WHEN** a person selects a different bounded value after receiving a suggestion
- **THEN** the system stores and summarizes the person's selection rather than the generated suggestion

### Requirement: Sensitive intelligence is on-device by default
The system SHALL use on-device processing for raw notes and personal event text
and SHALL NOT send that material to a remote model as part of this capability.

#### Scenario: Insight request uses a private note
- **WHEN** a note contributes to a tag or reflection request
- **THEN** the request uses an available on-device model or the deterministic fallback and does not transmit the note to an application server
