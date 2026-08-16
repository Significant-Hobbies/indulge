## Context

The app already has a SwiftUI onboarding shell, an original soft-form visual
world, four deterministic scene plates, Reduce Motion handling, and a 24-item
indulgence recipe catalog. The current customer flow is intentionally narrow
and does not yet retain a personal profile. See `proposal.md` for motivation and
`specs/personalized-onboarding/spec.md` for observable behavior.

## Goals / Non-Goals

**Goals:**

- Reach a genuine personalized first-value moment quickly without turning the
  opening into a form or assessment.
- Keep one question and one primary decision visible at a time.
- Reuse each meaningful answer later so the person feels listened to.
- Keep the state model deterministic enough for previews, tests, and screenshot
  evidence.

**Non-Goals:**

- Persisting answers after app termination.
- Requesting Screen Time authorization.
- Producing AI recommendations, diagnoses, or behavioural scores.
- Completing bespoke 3D art for every catalog item in this change.

## Decisions

### Use a typed local profile and explicit step state

A single `OnboardingProfile` value stores optional identity, selected
activities, timing, need, intent, desired life areas, and change pace. A typed
`PersonalOnboardingStep` enum owns order, progress, skip rules, and validation.
This keeps adaptive copy deterministic and testable. A dynamic remote survey
schema was rejected because V0 has no service and native polish matters more
than runtime question administration.

### Open on the first question and split value from deeper personalization

The flow opens directly on the preferred-name question. Its first-value journey
contains name, gender presentation, activities, primary indulgence, daily time,
underlying need, life direction, and a personalized reflection. Asking gender
second prevents the application from showing a feminine or masculine character
before the person chooses. From that reflection, the person can start using the
product or voluntarily answer common moment, starting pattern, intentionality,
and change pace before returning to a richer reflection. A separate editorial welcome
page remains rejected because it delays interaction and makes the opening feel
like a landing page.

This follows the locally retained Appnovation onboarding guide and current
Apple onboarding guidance: demonstrate value through interaction, postpone
nonessential setup, and use progressive disclosure. RevenueCat's activation
guidance further distinguishes first-value reach from mere onboarding
completion. The research application and source boundary live in
`docs/research/consumer-onboarding/README.md`.

### Make selection itself demonstrate the product

The most recently selected activity becomes the current primary preview so the
room responds on the selection screen rather than a later confirmation screen.
Watching TV uses the complete sofa/television scene. Scrolling uses the standing
character and animates a phone directly into the character's hand. Other
unfinished activities use the standing room with a truthful SF Symbol activity
medallion and activity-specific caption until authored scene art exists. The
following beat lets the person confirm or change the primary indulgence.

The discovery question asks which activities take more time than the person
wants, rather than which activities they enjoy. This separates the product's
target—time that has stopped feeling chosen—from intentional pleasure that does
not need intervention.

### Compose selected indulgences through deterministic scene sockets

The current most-recent-selection preview is an interim behavior, not the final
multi-select model. The overhaul gives each visible moment one foundation that
owns the environment, furniture, pose, and camera. Compatible selections attach
as companions to deterministic left-hand, right-hand, lap, side-table, or
ambient sockets. Preferred sockets resolve first; occupied or unsupported
sockets use an allowed fallback; unresolved additions stay visible in the
control layer with a plain explanation instead of replacing the scene or
floating without a physical relationship.

For example, television establishes the living-room sofa scene, scrolling puts
the phone in the right hand, smoking may use the left hand, and a drink falls
back to the side table. A second foundation that requires another room or pose
becomes a separate scene variant and is resolved by the following primary-
indulgence question. The selection UI must expose the current scene membership
and removal affordances while the scene itself proves the same stacking result.

### Treat personal data as local conversation state

No answer leaves the process or app bundle. Name and gender exist solely for
copy and visual personalization. The person chooses a gender presentation before
the character resolves; “Prefer not to say,” non-binary, and custom identities
retain a neutral abstract treatment. Gender never controls product access. A
custom identity value is short and displayed only in the current flow.

### Ask purpose directly and separately from automaticity

The first-value journey asks what the person is looking for when the primary
action begins. The prompt names that action—such as “When you start scrolling,
what are you looking for?”—and the choices answer it in natural phrases: a
chance to switch off, something comforting, a break from something, a little
stimulation, or a sense of connection. This purpose beat has no chapter label
or explanatory paragraph.

Whether the time still feels chosen is a different measurement. It remains in
deeper personalization under the direct question “How much of that time still
feels chosen?” rather than the ambiguous “How does it feel lately?”

### Build delight through continuity rather than spectacle

The current room persists while prompts change. Progress is a quiet narrative
thread; selections use material response and haptics; the character/scene
crossfades or subtly breathes. The final reflection gathers prior answers into
one humane paragraph. Confetti, scores, shock statistics, and generic success
illustrations are excluded.

The scene and prompt share one bounded viewport. The scene occupies the upper
stage, the current question lives in one native bottom tray, and the primary
action remains pinned while long answer lists scroll independently.

### Refine the established world with a native warm material system

The polish pass keeps the deep teal room and amber practical light, then adds
aubergine and clay warmth at the edges so the interface feels intimate rather
than nearly black. SF Pro Rounded is reserved for the wordmark and emotional
display prompts; explanatory copy, choices, and controls use the default SF Pro
Text cut for adult readability. These values live in shared SwiftUI tokens so
onboarding and subsequent native surfaces do not accumulate one-off RGB values.

iOS 18 MeshGradient provides the ambient color field and SwiftUI sensory
feedback replaces manually scattered haptic generators. On iOS 26 and newer,
small navigation controls may adopt native glass rendering; iOS 18–25 retain a
system-material fallback with the same size, contrast, and semantics. The
conversation panel remains a quiet material tray rather than decorative glass.
Direction-aware transitions preserve spatial understanding, and Reduce Motion
continues to replace travel with short fades.

### Let the opening question lead the interface

The first beat removes the centered wordmark, linear progress bar, chapter
label, scene caption, and explanatory paragraph. It presents only the optional
name question, one text field, and Continue. A
separate Skip action is excluded because Continue already accepts an empty
optional name.
Subsequent beats may show quiet textual progress such as “2 of 8,” but progress
must not compete with the current decision.

When a text field receives focus, the full cinematic stage collapses to a
compact safe-area header instead of being compressed above the software
keyboard. The prompt and anchored primary action remain comfortably visible.
This focus state is a designed composition and has a deterministic simulator
launch preset.

The scene art retains its authored evening colors, but onboarding chrome no
longer repeats the scene's teal and amber as large interface fills. The prompt
surface uses a near-black aubergine, interactive emphasis uses dusty lilac,
and the primary action uses a quiet light neutral with plum ink. Gold gradients
and green prompt trays are excluded.

### Make long-flow navigation reversible

Back preserves all answers. The optional opening name and voluntary detail
questions use the primary Continue action without adding a separate Skip label.
Required questions keep the primary action disabled until valid. Text-entry steps are scrollable
with keyboard dismissal. On iPad the stage and conversation sit side-by-side or
within separately constrained regions rather than stretching phone geometry.

## Risks / Trade-offs

- **A long mandatory intake withholds value** → Keep an eight-beat first-value
  journey and move the remaining four questions behind an optional deeper route.
- **Asking gender can feel invasive** → Ask only for character presentation,
  include self-description and non-disclosure, and retain neutral treatment when
  the person does not choose feminine or masculine artwork.
- **Only one finished indulgence scene exists** → Show the TV scene only for TV
  and use truthful abstract activity treatment for other choices.
- **Generated scene plates can feel visually richer than the simple product
  scope requires** → Keep controls and motion restrained; treat scene plates as
  the backdrop rather than adding more detailed art.
- **Newer native material APIs can fragment the look across iOS versions** →
  isolate them behind one modifier and keep an equivalent system-material
  fallback rather than branching the interaction model.
- **In-memory state is lost on termination** → Accept for the visual proof and
  add persistence in a later product change after the questions are validated.
