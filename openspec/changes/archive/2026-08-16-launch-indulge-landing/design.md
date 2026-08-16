## Context

See `proposal.md` for motivation. Indulge already has a private Significant-Hobbies repository, a mature native visual system, owned app screenshots, and a prepared privacy draft. The public surface must remain a provider-neutral static artifact that can support a later App Store/TestFlight launch without fabricating public availability or changing native app behavior.

## Goals / Non-Goals

**Goals:**

- Ship a static, fast, accessible public site that visibly belongs to the native app.
- Make the home, privacy, support, terms, accessibility, beta-status, and agent-discovery routes available without JavaScript.
- Keep TestFlight state truthful before and after an Apple public link exists.
- Establish a reproducible static build with CI coverage and no hosting-provider coupling.

**Non-Goals:**

- Add accounts, email capture, analytics, advertising, payments, testimonials, or a support backend.
- Change the iOS product, monetize it, claim clinical outcomes, or create a public TestFlight group before Apple-side configuration is ready.
- Copy a reference product's assets, copy, palette, typography, or proprietary interaction.

## Decisions

### Use Astro as a zero-hydration static site

The landing and legal content are text-and-image led, so Astro matches the Fleet standard and emits reviewable HTML with no client framework. CSS and a small progressive-enhancement script remain local; the site adds no runtime service or database. A single hand-authored HTML page was considered, but Astro gives route organization, reusable metadata/layout, build validation, and Markdown/API endpoints without shipping framework JavaScript.

### Preserve the native product world through “The Life Room” composition

The selected direction extends the Powder Sky/navy/cherry system and makes the owned blue room the page itself. A cherry path leaves the navy loop and connects intentional pleasure to small pockets of creativity, movement, relationships, and rest. The implementation uses semantic HTML/CSS/SVG plus existing raster assets; the generated comp at `artifacts/design/landing/probe-life-room.png` is a hierarchy and craft reference, not a screenshot to trace.

Current structural references contribute principles only:

- Apple Journal product storytelling: large owned product imagery, capability-by-capability explanation, and privacy as first-class proof.
- Brick: mechanism-first hero and a short numbered explanation that makes the action concrete.
- one sec: direct product demonstration and comprehensive support/legal discovery; its shame, addiction, extreme outcome language, proof density, and punitive framing are explicit anti-references for Indulge.

The alternate word-as-room and attention-thread probes remain review evidence but are not production structures. The former risks first-viewport legibility; the latter over-weights Focus relative to the full Life/Trade promise.

### Make TestFlight configuration build-time and fail honest

An optional public environment value supplies the Apple-hosted TestFlight URL. Without it, CTA copy and destination describe an invite-only beta and do not imply open enrollment. The site does not collect email addresses. This keeps the initial production deploy truthful while allowing a later link-only update.

### Reuse only owned app evidence

The web public directory receives copies of the selected app-store screenshots, brand mark, favicon, and a small set of life-direction images. Every product claim is backed by current app behavior or the project status. Generated direction probes do not ship as customer-facing product evidence.

### Keep hosting provider-neutral

The repository produces a deterministic static `dist` artifact and validates its routes locally and in CI. It contains no provider runtime, deploy script, project identifier, or domain-binding configuration. A hosting choice and any production publication are separate external-state decisions that require explicit authorization; they do not change the static-site contract.

### Keep repository and release history reviewable

Issue #5 owns the original work. The implemented static surface and its verification remain reviewable in repository history, while this reconciled change records that no production hosting or domain state is part of the completed scope. The OpenSpec change can be archived after the local build, required routes, and provider boundary pass verification.

## Risks / Trade-offs

- **A public TestFlight URL may not exist at first deploy** → Ship the honest invite-only beta page and switch the CTA only after Apple provides a valid URL.
- **Large screenshots can hurt LCP** → Use responsive crops, explicit dimensions, modern formats where quality holds, and lazy loading below the hero.
- **The cinematic room could become decorative rather than explanatory** → Keep the loop-to-path mechanism and primary action legible in static HTML, including with reduced motion.
- **The current privacy draft may overstate private CloudKit verification** → Describe preparation and optional Apple services separately from verified production sync.
- **A static artifact can be mistaken for a live public site** → Keep documentation explicit that no hosting, DNS, or public-availability claim is included.
- **TestFlight upload may expose Apple-side metadata gaps** → Upload without release, record exact App Store Connect errors, and keep site claims limited to the actual testing state.

## Migration Plan

1. Build and validate the site locally, including required routes and responsive evidence.
2. Run the path-scoped CI checks and verify the generated `dist` artifact contains every canonical route.
3. Remove provider-specific configuration and deployment scripts, then re-run the provider-boundary and static-output checks.
4. Archive the OpenSpec change and update durable project status with the verified local boundary.
5. If public hosting is authorized later, evaluate a provider and publication plan as a separate change. When Apple provides a public TestFlight URL, configure the static build truthfully; until then, keep the invite-only status.

Rollback is repository-local: restore the previous static artifact or source revision. There is no hosting or DNS state to roll back in this change.
