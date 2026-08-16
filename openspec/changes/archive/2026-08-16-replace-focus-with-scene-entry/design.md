## Context

See `proposal.md` for motivation. The native shell currently exposes Life,
Focus, Trade, and History. Focus also influences automatic launch routing and
privacy copy. Its SwiftData records participate in the versioned schema and
prepared private CloudKit store, so deleting those types would turn a product
simplification into a risky data migration.

## Goals / Non-Goals

**Goals:**

- Reduce the visible application to Life, Trade, and History.
- Let the authored room itself open the existing Trade decision.
- Keep an update safe for stores that already contain Focus records.
- Keep the native app independent from the repository's Cloudflare-hosted site.

**Non-Goals:**

- Exporting or visualizing legacy Focus records.
- Creating a replacement productivity tracker, interruption journal, timer, or
  automatic app-switch monitor.
- Removing the static website or its Cloudflare Pages deployment.
- Changing CloudKit containers, entitlements, or the persistent schema version.

## Decisions

### Remove the surface, not the persisted types

The Focus tab, preview presets, launch routing, startup repair, and visible copy
are removed. Focus model and migration types remain compiled into the schema.
This is safer than deleting them and accurately distinguishes a retired feature
from destructive data erasure.

### Make the scene the action

Life wraps its existing full-width scene in a semantic button. A small caption
inside the lower scene edge reads “Tap the room when it starts,” and the room
uses the existing press-depth language before selecting Trade. This avoids a
new card or modal and makes the product's strongest visual asset do real work.
The existing first-trade invitation remains as an explicit alternative and
accessibility fallback.

### Route retired Focus launch arguments to Life

Deterministic development arguments are accepted for compatibility but resolve
to Life. Removing the cases entirely would make old screenshot scripts open an
unpredictable automatic route.

### Keep Cloudflare outside the native boundary

No native code calls Cloudflare. Wrangler, Astro output, and Pages configuration
remain solely for the public website. Native persistence remains SwiftData with
prepared private CloudKit sync.

## Risks / Trade-offs

- **Legacy code remains in the binary** → Keep it internal and unreachable;
  remove it only through a separately tested schema migration later.
- **A tappable image may be undiscoverable** → Use a concise scene-edge cue,
  button semantics, pressed depth, and retain the explicit Trade invitation.
- **Three tabs can feel sparse** → Treat the simplification as clarity; do not
  invent a replacement destination merely to fill the bar.

## Migration Plan

1. Remove Focus navigation and public routing while keeping schema types.
2. Add scene-entry behavior and update visible privacy/authentication copy.
3. Update tests and durable product/design truth.
4. Build against the existing store schema and run the complete test suite.
5. Roll back by restoring navigation; no data migration reversal is required.
