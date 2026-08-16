# focus-interruption-journal Specification

## Purpose
Defines a private, manual record of focused work, attention interruptions, recovery cost, and evidence-bounded patterns that remain useful without automatic monitoring or AI availability.
## Requirements
### Requirement: Legacy Focus data remains migration-safe
The application SHALL retain existing Focus persistence types internally while
the Focus customer surface is retired, so installing an update does not require
destructive migration or silently delete previously stored records.

#### Scenario: Existing installation updates
- **WHEN** an installation containing Focus records opens the updated application
- **THEN** its persistent store opens successfully without exposing Focus as a tab or launch destination
