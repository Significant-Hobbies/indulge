# Visual proof performance verification

Verified on 2026-08-11 with the generated Debug simulator build and the
auto-playing `--review` route.

| Runtime | Test result | Review-route RSS | Review-route CPU |
| --- | --- | ---: | ---: |
| iOS 26.4, iPhone 17 Pro simulator | 38 tests passed | 290,912 KB, stable across eight one-second samples | 8.6–18.7% |
| iOS 27.0 beta, iPhone 17 Pro simulator | 38 tests passed | 430,400–432,160 KB after launch settled | 5.9–11.1% after launch settled |

The simulator build also completed with code signing disabled. The review route
played the authored assembly in order on both runtimes without an observed
stall, missing phase, or process termination.

These are simulator process samples from `simctl spawn ... ps`; they are useful
for regression comparison but are not physical-device energy measurements.
Instruments reported that Activity Monitor and Animation Hitches are unsupported
for these simulator targets, so the empty trace bundles are excluded from git.
Thermal state, battery impact, and hardware frame pacing remain TestFlight/device
checks and must not be inferred from this simulator run.
