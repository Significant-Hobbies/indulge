# Visual proof performance verification

Verified on 2026-08-11 with the generated Debug simulator build and the
auto-playing `--review` route.

| Runtime | Test result | Review-route RSS | Review-route CPU |
| --- | --- | ---: | ---: |
| iOS 26.4, iPhone 17 Pro simulator | 71 tests passed | 297,712 KB across eight one-second samples | 9.9–14.9% after launch settled |
| iOS 27.0 beta, iPhone 17 Pro simulator | 71 tests passed | 435,520 KB across eight one-second samples | 11.6–15.4% after launch settled |

The simulator build also completed with code signing disabled. The review route
played the authored assembly in order on both runtimes without an observed
stall, missing phase, or process termination.

These are simulator process samples from `simctl spawn ... ps`; they are useful
for regression comparison but are not physical-device energy measurements.
Instruments reported that Activity Monitor and Animation Hitches are unsupported
for these simulator targets, so the empty trace bundles are excluded from git.
Thermal state, battery impact, and hardware frame pacing remain TestFlight/device
checks and must not be inferred from this simulator run.

The paired iPhone became available during this verification pass, but the signed
device build stopped before install: the current local provisioning profile does
not contain the target's checked-in iCloud and Push Notifications capabilities.
No production capability or signing configuration was weakened to bypass that
boundary. Hardware frame pacing, thermal state, and battery impact therefore
remain explicitly unverified.
