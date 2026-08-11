# TestFlight preparation

Indulge is configured as iOS version `0.1.0`, build `1`, with bundle identifier
`com.significanthobbies.indulge`. The App Store icon is present in `AppIcon`,
and the checked-in Info.plist declares that the current app does not use
non-exempt encryption.

## Account boundary

The Xcode project is pinned to personal team `8F7LXHTJZR`, whose installed
signing certificate is owned by `Sarthak Agrawal`. It does not select or fall
back to a Vault organization team.

The archive and upload scripts enforce the same boundary and abort if either
the archive or export configuration names another team. The Apple ID may have
access to multiple App Store Connect providers; the Indulge app record must be
created under the provider whose team identifier is `8F7LXHTJZR`, never merely
the first provider shown after sign-in.

A free Apple Account can run this build directly on a personal iPhone through
Xcode, but Apple does not provide App Store Connect or TestFlight distribution
to Personal Teams. Free provisioning expires after seven days, so the app must
be rebuilt and installed again periodically. TestFlight requires an active
Apple Developer Program membership.

The checked-in export options are also pinned to this personal team and to
TestFlight Internal Only. An internally uploaded build cannot later be shared
with external testers or submitted to the App Store.

For free personal-device testing, connect and unlock the iPhone, enable
Developer Mode, select it as Xcode's run destination, and press Run. Xcode can
create the personal provisioning profile automatically when the Apple Account
is signed in under Xcode > Settings > Accounts.

An earlier signed archive predates the selected production icon and is not
accepted as current readiness evidence. TestFlight upload is now authorized;
App Store submission and public release are not.

## Verified local readiness

On 2026-08-11, the generated project completed an unsigned Release build for a
generic iOS Simulator destination. The 1024×1024 shipping icon is opaque, the
32px and 64px favicon exports are present, the privacy manifest declares the
app-local UserDefaults reason, the privacy manifest and export options pass
`plutil`, and both shell scripts pass `zsh -n`. The prepared opaque JPEG store
screenshots are 1320×2868 for iPhone 6.9-inch and 2064×2752 for iPad 13-inch.

This check proves local Release compilation and package preparation. The
current icon also completed an unsigned generic-device archive at
`build/Indulge-Unsigned.xcarchive`. Its bundle identity is
`com.significanthobbies.indulge` version `0.1.0` build `1`; its bundled privacy
manifest passes `plutil`; and its compiled 120px phone and 152px iPad icon
renditions contain the selected sprout mark. The archive is local evidence only
and is not signed or distributable.

These checks do not replace App Store Connect record creation, upload
processing, tester invitation, or release. Those remain separate steps below.

## Current upload state

On 2026-08-11, Xcode reached App Store Connect with the signed personal-team
archive and returned `App record with bundle identifier
"com.significanthobbies.indulge" not found`. The archive and export settings
passed the local personal-team boundary before transport. Create the Indulge
app record in the personal App Store Connect provider, then rerun the upload
script. Do not substitute another developer team.

## Beta information

### Beta app description

Indulge helps you notice where your time gets pulled away, keep the pleasures
you choose, and make room for more of the life you want. This early build pairs
a personal, visual onboarding with a private Focus journal for interruptions
and recovery.

### What to test

1. Complete onboarding and choose more than one activity that takes longer than
   intended.
2. Confirm the room and character respond to activity, presentation, and
   companion choices without changing identity between scenes.
3. Open Focus, start a session, record an interruption, classify what pulled
   you away, record what made returning difficult, and return to the session.
4. Check that the daily Focus summary reflects the interruption and recovery
   time.
5. Relaunch the app and confirm your local profile and Focus history remain.
6. Try Larger Text, VoiceOver, and Reduce Motion and report anything clipped,
   hidden, or unclear.

### Known limitations

- Screen Time authorization and automatic activity history are not included in
  this build.
- Data remains local to the device; iCloud sync is not active yet.
- Private iCloud sync is prepared but remains unverified until the development
  container and two signed devices complete the checklist in
  `docs/CLOUDKIT_PREPARATION.md`.
- On-device Focus tag suggestions and grounded reflection selection appear only
  on supported Apple Intelligence devices. Manual classification and authored
  reflections remain available everywhere.
- Optional Image Playground card creation appears only on supported devices.
- Privacy Lock is optional and uses Face ID, Touch ID, or the device passcode.
- Trade and History are still early product surfaces.

## Before the first upload

- Create the App Store Connect app record with bundle ID
  `com.significanthobbies.indulge` if it does not already exist.
- For TestFlight, enroll the personal account in the Apple Developer Program
  or explicitly choose another paid team. Do not substitute the Vault team.
- Add the required TestFlight feedback email. It is intentionally not invented
  or committed here.
- Complete the current age-rating questionnaire, privacy details, and any
  territory compliance required by App Store Connect.
- Confirm the export-compliance answer remains accurate if cryptography or a
  third-party SDK is added later.
- Increment `CURRENT_PROJECT_VERSION` for every uploaded build.

## Build and archive

Run the local checks first:

```sh
./scripts/test.sh
./scripts/build.sh
```

Then create a signed archive with the Apple Developer team identifier shown in
Xcode under Signing & Capabilities:

```sh
./scripts/archive-testflight.sh
```

If Xcode is signed in to the intended developer account but the local profile
has not been downloaded yet, explicitly allow Xcode to manage it:

```sh
INDULGE_ALLOW_PROVISIONING_UPDATES=YES \
./scripts/archive-testflight.sh
```

The archive is written to `build/Indulge.xcarchive`. Open it in Xcode Organizer
to inspect it if needed. The scripted upload below remains locked to TestFlight
Internal Only and cannot submit a build for App Store review.

After the app record exists, upload the already signed personal-team archive as
an internal-only build with:

```sh
./scripts/upload-testflight-personal.sh
```
