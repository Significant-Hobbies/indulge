## Purpose

Turns Indulge’s daily promise into a durable, non-judgmental loop that a person can start, finish, revisit, and understand without an account or network connection.

## ADDED Requirements

### Requirement: One trade remains durable across launches
The application SHALL persist at most one active trade with a stable identifier, selected indulgence, reclaim duration, life direction, creation time, and start time so the same trade returns after relaunch.

#### Scenario: Application relaunches with an active trade
- **WHEN** a person closes and reopens Indulge after creating or beginning a trade
- **THEN** the Life and Trade surfaces show the same active trade rather than asking the person to recreate it

#### Scenario: Application is offline
- **WHEN** a person creates or updates a trade without network access
- **THEN** the action completes locally and remains available after relaunch

### Requirement: A person can finish without being judged
The application SHALL let a person finish the active trade by recording whether they made the intended room, deliberately kept enjoying the indulgence, or chose to leave the trade for another day.

#### Scenario: Reclaimed time is completed
- **WHEN** a person finishes a trade after making room for the selected direction
- **THEN** the application records the truthful completion time and outcome, clears the active slot, and presents a calm completion response

#### Scenario: Intentional indulgence is completed
- **WHEN** a person decides to keep enjoying the indulgence and records that choice
- **THEN** the application preserves it as an intentional outcome without failure language, punishment, or a negative score

### Requirement: History is derived from completed records only
The application SHALL show a chronological history and small factual summaries calculated only from persisted completed trades.

#### Scenario: No trade has been completed
- **WHEN** History has no completed records
- **THEN** it shows an honest empty state and a route to create a trade without synthetic charts or claims

#### Scenario: Completed trades exist
- **WHEN** History loads one or more completed records
- **THEN** it shows their dates, indulgences, destinations, planned minutes, and recorded outcomes using locale-aware formatting

### Requirement: Active trade replacement is deliberate
The application SHALL prevent an accidental second active trade and SHALL require a clear confirmation before replacing an existing one.

#### Scenario: Person creates another trade while one is active
- **WHEN** the person attempts to create a different trade before finishing the current one
- **THEN** the application offers to keep the current trade or replace it and preserves the current trade unless replacement is confirmed

### Requirement: Deletion covers trade data
The application SHALL include active and completed trade records in its confirmed all-data deletion behavior.

#### Scenario: Person confirms all-data deletion
- **WHEN** the person confirms deletion in privacy settings
- **THEN** active and completed trades are removed with the profile and generated card data
