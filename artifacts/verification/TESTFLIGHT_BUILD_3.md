# Indulge 0.1.0 build 3 — TestFlight upload evidence

Recorded on 16 August 2026.

## Candidate identity

- Bundle ID: `com.significanthobbies.indulge`
- Version/build: `0.1.0 (3)`
- Team: `8F7LXHTJZR`
- Archive: `build/Indulge-Build3-TestFlight.xcarchive`
- Inspected package: `build/TestFlightPackageBuild3/Indulge.ipa`

## Distribution package gate

- Signing authority: `Apple Distribution: Sarthak Agrawal (8F7LXHTJZR)`
- `get-task-allow`: `false`
- Push environment: `production`
- iCloud environment: `Production`
- Privacy manifest: valid
- Embedded frameworks: `0`
- Classification: `testflight-package-ready`

## Apple transport result

`xcodebuild -exportArchive` authenticated with the intended Apple team,
completed package analysis, transferred `Indulge.ipa` to 100%, and reported:

```text
Uploading “Indulge.ipa” is complete.
Uploaded package is processing.
Upload succeeded.
```

The upload was restricted to TestFlight internal testing. It did not submit
the app for App Store review, enable external testing, invite testers, promote
the CloudKit production schema, or use the Vault team. App Store Connect portal
confirmation of `Ready to Test` remains pending an authenticated web session.
