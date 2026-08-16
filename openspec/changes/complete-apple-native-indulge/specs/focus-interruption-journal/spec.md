## ADDED Requirements

### Requirement: Legacy Focus data stays outside active product behavior
The application SHALL retain legacy Focus persistence types only for migration compatibility and SHALL NOT use those records to populate Trade, History, reflection, or optional intelligence features.

#### Scenario: Existing Focus records are present
- **WHEN** an updated installation opens a store containing legacy Focus records
- **THEN** the store opens successfully while the active product shows only Indulge trade data and scene-led behavior
