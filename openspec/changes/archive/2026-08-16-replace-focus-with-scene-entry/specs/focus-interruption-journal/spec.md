## ADDED Requirements

### Requirement: Legacy Focus data remains migration-safe
The application SHALL retain existing Focus persistence types internally while
the Focus customer surface is retired, so installing an update does not require
destructive migration or silently delete previously stored records.

#### Scenario: Existing installation updates
- **WHEN** an installation containing Focus records opens the updated application
- **THEN** its persistent store opens successfully without exposing Focus as a tab or launch destination

## REMOVED Requirements

### Requirement: Focus is a primary product destination
**Reason**: A productivity-oriented fourth tab conflicts with Indulge's scene-led indulgence model.
**Migration**: Life, Trade, and History remain; launch and preview routes that previously selected Focus resolve to Life.

### Requirement: Focus sessions preserve their real timing
**Reason**: Focus sessions are no longer part of the customer experience.
**Migration**: Existing records remain stored for schema compatibility but no new session can be started from the mobile interface.

### Requirement: One action records an interruption immediately
**Reason**: Interruption tracking is being removed from the consumer application.
**Migration**: No replacement interruption action is exposed; the Life scene opens an intentional Trade instead.

### Requirement: Interruptions capture reason and return blockage
**Reason**: Reason and blockage classification belong to the retired Focus workflow.
**Migration**: Existing classifications remain migration-safe and invisible.

### Requirement: Daily summaries use recorded evidence only
**Reason**: Focus daily summaries are being removed with the Focus surface.
**Migration**: History continues to describe Indulge trades and life direction rather than interruption analytics.

### Requirement: Aggregate insights require enough observations
**Reason**: Focus-derived behavioral generalization is outside the simplified Indulge product boundary.
**Migration**: Indulge retains its authored, profile-grounded reflection and does not surface legacy Focus aggregates.

### Requirement: Recording remains local-first and AI-optional
**Reason**: Focus recording is no longer customer-facing.
**Migration**: The native app remains local-first and private-CloudKit-ready for its remaining profile and trade data.

### Requirement: Ordinary app switching is not an interruption
**Reason**: The application no longer creates or exposes interruption events of any kind.
**Migration**: No app switching is monitored, classified, or inferred.
