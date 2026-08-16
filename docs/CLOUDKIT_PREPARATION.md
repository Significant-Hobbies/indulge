# Private CloudKit preparation

Indulge is prepared for local-first SwiftData synchronization through a private
CloudKit database. This document records configuration truth; it is not evidence
that synchronization is live.

## Selected development configuration

- Apple Developer team: `8F7LXHTJZR`
- App bundle identifier: `com.significanthobbies.indulge`
- Configured private container: `iCloud.com.significanthobbies.indulge`
- Environment in checked-in entitlements: `Development`
- Background delivery: `remote-notification`
- Production schema promotion: not authorized

The versioned models use stable UUID attributes without uniqueness constraints,
have no relationships, and give every required stored attribute a default. Test,
preview, simulator, and explicit-store configurations disable CloudKit. A signed
device build selects the exact private container; if that container cannot be
opened, app startup retries with the local-only configuration.

## External blockers

The repository cannot prove any of the following without Apple Developer portal
and physical-device work:

1. The configured container exists under team `8F7LXHTJZR` and is attached to the
   App ID and development provisioning profile.
2. The development provisioning profile's container association works during
   an authenticated CloudKit operation. The signed archive does contain the
   expected development push and iCloud entitlements.
3. Offline writes later synchronize in both directions across two signed devices.
4. Stable-ID duplicates and competing active sessions converge after delayed sync.
5. Confirmed all-data deletion propagates to both private databases.
6. The development schema is ready for production promotion.

Do not claim sync is active, change the container environment to Production, or
promote the CloudKit schema until items 1–5 have recorded evidence and the owner
separately authorizes the release step.

## Development verification checklist

1. Confirm the container and App ID association in the intended Apple Developer team.
2. Refresh the development profile and archive a signed build without changing teams.
3. Inspect the signed app entitlements for the exact container, CloudKit service,
   and development push environment.
4. Install the same build on two devices signed into the intended iCloud test account.
5. Record an offline profile and Trade on device A; reconnect and verify it
   appears on device B without duplicate observations.
6. Create competing active sessions offline, reconnect, and verify deterministic repair.
7. Confirm deletion on one device and verify profile, Trade, legacy migration
   records, generated reflection, and future-life-card metadata disappear from both devices.
8. Re-run the local test suite and preserve screenshots/logs before requesting any
   production-schema promotion.
