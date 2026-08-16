## Why

Focus interruption tracking and Indulge's visual, indulgence-first experience
ask people to adopt two different mental models inside one mobile application.
The resulting Focus tab makes Indulge feel like a productivity tracker and
weakens the scene-led product promise.

## What Changes

- **BREAKING**: Remove Focus as a visible app tab, automatic launch destination,
  preview route, and customer-facing concept.
- Make the Life scene the primary interaction surface: a person taps the scene
  when an indulgence is beginning and moves directly into the existing Trade
  decision without first visiting a dashboard or tracker.
- Preserve legacy Focus records and schema types internally so an update never
  destroys previously stored data or breaks CloudKit/SwiftData migration.
- Remove Focus language from privacy, authentication, navigation, and durable
  product/design documentation.
- Keep Cloudflare isolated to the separate static marketing website; the native
  app continues to use local SwiftData and prepared private CloudKit only.

## Capabilities

### New Capabilities

- `scene-led-indulgence-entry`: The authored Life scene acts as the direct,
  accessible entry into an intentional Trade.

### Modified Capabilities

- `focus-interruption-journal`: The mobile Focus journal is retired from the
  customer experience while its legacy persistence remains migration-safe.

## Impact

- Affects the SwiftUI app shell, launch routes, Life scene header interaction,
  privacy copy, previews, tests, PRODUCT.md, and DESIGN.md.
- Does not delete data, remove SwiftData schema types, change CloudKit
  containers, add dependencies, or touch the Cloudflare Pages marketing site.
