## Why

Indulge has a tested native experience and prepared App Store materials, but its public domain does not resolve and there is no trustworthy place for a tester to understand the product, join TestFlight, reach support, or read the privacy policy. A complete public surface is needed now that testing is moving from simulators to TestFlight.

## What Changes

- Add a responsive Indulge landing page that extends the established product identity and demonstrates the real app through existing scene and simulator assets.
- Provide one primary TestFlight action with an honest pre-link state until Apple supplies the public testing URL.
- Publish accurate privacy, support, terms, accessibility, and product-fit content without invented testimonials, pricing, benchmarks, or clinical claims.
- Add agent-readable discovery through `llms.txt`, public Markdown, and `/api/ai`.
- Add a minimal Astro build, CI coverage, and deterministic provider-neutral static output.
- Update durable project documentation with the verified local launch-surface boundary; publishing remains a separately authorized action.

## Capabilities

### New Capabilities

- `public-launch-surface`: Covers the public landing experience, tester action, product proof, legal/support routes, accessibility and responsive behavior, agent-readable discovery, and production availability.

### Modified Capabilities

None.

## Impact

- Adds an Astro-based static site and its package-manager manifest alongside the native Xcode project.
- Adds generated web output and CI validation without provider runtime, deployment configuration, or a repository-local deploy command.
- Reuses owned Indulge imagery and copy; no app runtime dependency or native behavior changes.
- Produces a static `dist` artifact that can be hosted later without coupling the repository to a provider.
- Does not deploy, connect a domain, or claim that privacy and support URLs are publicly reachable.
