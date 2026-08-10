## Purpose

Keep a person's Indulge profile and history durable across their Apple devices
without turning account creation or network availability into a prerequisite.

## ADDED Requirements

### Requirement: Local-first persistence remains authoritative
The system SHALL write profile, focus, and generated product state to local
persistent storage before depending on any cloud synchronization result.

#### Scenario: Device is offline
- **WHEN** a person records or edits Indulge data without a network connection
- **THEN** the action completes locally and remains available after relaunch

### Requirement: Private Apple-device synchronization is optional infrastructure
The system SHALL synchronize supported records through the person's private
Apple cloud database when configured and available, without presenting a custom
sign-in wall.

#### Scenario: Private sync is available
- **WHEN** the application has a valid private-cloud configuration and the device is signed into the required Apple service
- **THEN** compatible records synchronize across the person's devices without exposing them to other users

#### Scenario: Private sync is unavailable
- **WHEN** cloud capabilities, account state, or network access are unavailable
- **THEN** the application continues with local persistence and does not claim that unsynchronized data is synchronized

### Requirement: Synced records converge without duplicate behavioral events
The system SHALL use stable identifiers and startup repair rules so the same
session or interruption does not become multiple behavioral observations after
multi-device synchronization.

#### Scenario: The same event arrives more than once
- **WHEN** synchronization delivers records that share a stable event identifier
- **THEN** the system retains one logical observation and preserves the most complete valid state

#### Scenario: Two devices leave sessions active
- **WHEN** synchronized state contains multiple open sessions or interruptions
- **THEN** the system applies deterministic repair and retains one active chain without deleting completed history

### Requirement: Synced personal data can be removed
The system SHALL provide one deliberate deletion action for locally stored and
privately synchronized Indulge data, with a destructive confirmation before it runs.

#### Scenario: Person confirms deletion
- **WHEN** a person confirms deletion of all Indulge data
- **THEN** the system removes eligible local records and requests removal of their private synchronized copies
