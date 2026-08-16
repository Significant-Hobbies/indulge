> Current-release reconciliation (2026-08-16): the visual proof is integrated
> into the Life → Trade → History product and verified across the installed
> simulator matrix. Task 6.2 remains open because frame pacing, memory, and
> thermal measurements were not captured. Task 6.6 remains open until the owner
> records a final keep/close/wrong-lane decision.

## 1. Project and Review Scaffold

- [x] 1.1 Confirm the owning GitHub organization and repository visibility,
  create the independent repository, and open the visual-proof implementation
  issue because Significant Hobbies issue #65 is reference-only.
- [x] 1.2 Scaffold the native iOS app target, test target, app icon placeholder,
  local build configuration, and CI build/test command without third-party
  runtime dependencies.
- [x] 1.3 Add project-level `AGENTS.md`, `README.md`, `PROJECT_STATUS.md`, and an
  asset-provenance manifest consistent with Fleet project standards.
- [x] 1.4 Verify and document the minimum iOS version and oldest installed matching
  simulator supported by the chosen `RealityView` and animation APIs.

## 2. Scene and Catalog Model

- [x] 2.1 Implement `LifeSceneState`, indulgence identifiers, companion
  identifiers, scene phases, progress values, and deterministic demo fixtures.
- [x] 2.2 Implement reusable recipe types for base pose, environment cluster,
  camera target, prop sockets, ambient loops, arrival phases, and explicit-only
  sensitive companions.
- [x] 2.3 Author the initial 20–30-item indulgence catalog across watching,
  handheld scrolling, desk/browsing, gaming, listening, eating/drinking,
  shopping, resting, and social-connection mechanics.
- [x] 2.4 Author the pose/socket compatibility matrix and deterministic fallback
  for visually impossible combinations.
- [x] 2.5 Add strict catalog validation tests for identifier count, referenced
  assets, sockets, poses, transition phases, and exclusion of explicit-only
  companions from defaults.

## 3. Original Soft-Form Entity Kit

- [x] 3.1 Build shared matte materials, scene lighting, fixed perspective camera,
  contact-shadow treatment, and deep-teal stage matching `DESIGN.md`.
- [x] 3.2 Build an original procedural adult character hierarchy with stable
  root, torso, head, arm, hand, leg, and prop-socket entities.
- [x] 3.3 Build original modular watching assets: floor stage, sofa modules,
  television, stand, lamp, phone, mug, wine glass, and neutral smoking prop.
- [x] 3.4 Build representative possible-life assets for reading, movement,
  creating, restoring, and connection using the same soft-form grammar.
- [x] 3.5 Add an asset-role loader that can later replace procedural entities with
  Reality Composer Pro or USDZ assets without changing recipes.

## 4. Scene Composition and Motion

- [x] 4.1 Implement the scene coordinator that maps `LifeSceneState` to entity
  transforms, visibility, materials, pose targets, camera framing, and semantic
  summary.
- [x] 4.2 Implement cancellable named transition sequencing and ensure a new state
  continues from currently presented transforms without duplicate entities.
- [x] 4.3 Implement the approved watching sequence: standing character, stage and
  sofa arrival, character sit, television arrival, lamp settle, and bounded
  ambient loop.
- [x] 4.4 Implement detachable hand-prop arrival and pose coupling for mug, wine
  glass, phone, and the explicit-only smoking prop.
- [x] 4.5 Implement the continuous Now ↔ Possible scrub using persistent sofa/TV
  objects and interpolated possible-life space, objects, posture, and camera.
- [x] 4.6 Implement replayable present-life reveal, trade transform, replacement
  completion, weekly morph, and graduation transitions in the same world.
- [x] 4.7 Add restrained confirmation/settle haptics and pause ambient loops during
  every hero transition.

## 5. Native Review Experience

- [x] 5.1 Build the SwiftUI review flow with real onboarding copy, native choice
  controls, one contextual action tray, and a hero-beat replay surface.
- [x] 5.2 Add native Now ↔ Possible scrub interaction and expose the selected
  indulgence and companion recipe without a generic dashboard.
- [x] 5.3 Implement ordered crossfade/in-place Reduce Motion recipes for every
  hero transition.
- [x] 5.4 Add one coherent VoiceOver scene summary, 44pt controls, Dynamic Type
  reflow, increased contrast, and differentiate-without-color states.
- [x] 5.5 Add UI and state previews for watching alone, watching with wine,
  possible life, completed replacement, history morph, graduation, and Reduce
  Motion.

## 6. Verification and Design Review

- [x] 6.1 Run focused unit tests for scene recipes, catalog validation,
  compatibility fallback, interruption, and Reduce Motion selection.
- [ ] 6.2 Build and run the visual proof on the oldest and newest supported iPhone
  simulators, recording frame pacing, memory, and any thermal/battery concern.
- [x] 6.3 Capture design evidence at phone, tablet, and wide review widths and in
  both standard and Reduce Motion modes.
- [x] 6.4 Run Impeccable critique, fix every P0/P1, run polish and native audit,
  and record scores plus advisory detector findings in the design receipt.
- [x] 6.5 Run the project check, `git diff --check`, OpenSpec strict validation,
  and a final independent finish review against the approved A+C comps.
- [ ] 6.6 Present the simulator proof for owner `keep`, `close`, or `wrong-lane`
  feedback and record the decision before claiming the visual change complete.
