## Purpose

Defines a scalable catalog of indulgence and companion recipes that can cover
roughly 20–30 recognizable habits without requiring a bespoke renderer or
one-off animation implementation for every combination.

## ADDED Requirements

### Requirement: Every indulgence is a validated scene recipe
Each bundled indulgence SHALL declare a stable identifier, display label,
activity family, base pose, environment cluster, camera target, ambient-loop
set, arrival sequence, and compatible companion sockets.

#### Scenario: Catalog loads a watching recipe
- **WHEN** the catalog resolves the watching-TV identifier
- **THEN** it returns a complete recipe that can compose the watching pose, sofa
  cluster, television, lamp, camera, and compatible companions without custom
  view code

### Requirement: Catalog breadth uses a finite reusable vocabulary
The V1 catalog SHALL cover between 20 and 30 indulgence identifiers using a
bounded set of shared poses, environment modules, prop sockets, and transition
phases.

#### Scenario: Catalog coverage is validated
- **WHEN** the catalog validation suite inspects all bundled recipes
- **THEN** it finds 20–30 unique identifiers and no recipe references a missing
  pose, module, socket, or transition phase

### Requirement: Compatibility is explicit
A companion prop SHALL declare the body or environment sockets and base poses it
supports. The system MUST reject or substitute a safe neutral fallback for an
unsupported combination instead of displaying a floating, intersecting, or
physically impossible prop.

#### Scenario: Companion cannot attach to the current pose
- **WHEN** a selected companion has no compatible socket on the active pose
- **THEN** the app leaves the companion out of the scene, preserves the rest of
  the recipe, and provides a deterministic non-shaming fallback state

### Requirement: Couplings are curated scene compatibility, not behavioral claims
The catalog SHALL describe which visual modules can compose cleanly and MUST NOT
claim that a pairing is statistically probable, healthy, desirable, or
recommended without separate verified evidence.

#### Scenario: Watching supports multiple companions
- **WHEN** the catalog lists phone, snack, warm drink, wine, or smoking props as
  visually compatible with watching
- **THEN** that compatibility controls composition only and is not presented to
  the user as evidence that people should or usually combine those behaviors

### Requirement: Sensitive companions are explicit-only
Alcohol and smoking companions SHALL be tagged as explicit-only and MUST NOT
appear in default suggestions, automatic pairings, replacement recommendations,
celebration states, or first-run demo choices.

#### Scenario: Default recommendation is requested
- **WHEN** the app asks the catalog for a default companion to a watching recipe
- **THEN** the result excludes every explicit-only companion

### Requirement: Catalog changes do not require renderer changes
Adding a recipe that uses existing poses, modules, sockets, and transition phases
SHALL require only catalog data and validation updates.

#### Scenario: A new streaming subtype is added
- **WHEN** an author adds a documentary-streaming recipe using existing watching
  assets and compatible props
- **THEN** the recipe can be rendered and tested without modifying the scene
  coordinator or SwiftUI surface
