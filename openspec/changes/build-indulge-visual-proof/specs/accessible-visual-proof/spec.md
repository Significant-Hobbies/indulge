## Purpose

Defines a native fake-data proof that preserves meaning, dignity, and operability
for users who rely on iOS accessibility settings or cannot perceive spatial
motion.

## ADDED Requirements

### Requirement: Reduce Motion preserves causal meaning
When Reduce Motion is enabled, the app SHALL replace camera travel, parallax,
large object movement, and overshoot with crossfades and in-place state changes
while preserving the order and meaning of each transformation.

#### Scenario: Watching selection with Reduce Motion
- **WHEN** Reduce Motion is enabled and the user selects watching TV
- **THEN** the stage, furniture, and watching pose appear through ordered
  crossfades without spatial flight, scale overshoot, or camera movement

### Requirement: The scene has a semantic summary
The 3D scene SHALL expose a concise accessibility description of the current
character activity, important objects, and scene change without requiring a
screen reader user to traverse decorative entities.

#### Scenario: VoiceOver focuses the life scene
- **WHEN** VoiceOver focus reaches the scene
- **THEN** it announces the current activity and meaningful additions as one
  coherent summary before the user moves to the controls

### Requirement: Controls remain native and accessible
Every interactive control SHALL have a minimum 44×44pt target, Dynamic Type
support, a visible non-color selection state, and a label that describes its
action.

#### Scenario: User selects with accessibility text sizes
- **WHEN** the user enables an accessibility Dynamic Type size
- **THEN** choice and action controls reflow without truncating their action
  labels or overlapping the scene interaction area

### Requirement: Increased contrast preserves the art direction
When increased contrast or differentiate-without-color is enabled, controls and
scene-state cues SHALL gain shape, weight, or tonal separation without changing
the product into a warning-colored or morally coded experience.

#### Scenario: Increased contrast is enabled
- **WHEN** the app receives an increased-contrast accessibility environment
- **THEN** selected states and critical silhouettes remain distinguishable
  without relying only on hue or adding red failure treatment

### Requirement: The proof is deterministic and offline
The complete review flow SHALL run from bundled fake data without an account,
network connection, Screen Time permission, analytics, or private user data.

#### Scenario: Device is offline
- **WHEN** the visual proof launches without network connectivity
- **THEN** every scene state and hero animation remains available and produces
  no sign-in or permission blocker

### Requirement: Sensitive companion props remain neutral context
Alcohol or smoking props MUST appear only after an explicit user-declared choice
and MUST NOT be suggested as probable, framed as a reward, scored, celebrated,
or presented as clinical guidance.

#### Scenario: User has not declared a sensitive companion
- **WHEN** the reviewer traverses default suggestions and scene recipes
- **THEN** alcohol and smoking options do not appear as recommended companions

#### Scenario: User explicitly declares a sensitive companion
- **WHEN** the user chooses a supported alcohol or smoking context for their own
  scene
- **THEN** the scene mirrors it with neutral language and motion and provides no
  consumption advice, health claim, or celebratory effect
