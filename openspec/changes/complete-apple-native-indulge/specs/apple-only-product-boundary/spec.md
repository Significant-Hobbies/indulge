## Purpose

Keeps Indulge’s application behavior, private persistence, optional intelligence, and release configuration within Apple’s platform while removing Cloudflare-specific infrastructure.

## ADDED Requirements

### Requirement: Core application runtime uses Apple platform capabilities only
The native application SHALL use Apple system frameworks and bundled assets for its production runtime and SHALL NOT require a Cloudflare service, web view, application backend, or third-party production package.

#### Scenario: Application launches without external connectivity
- **WHEN** the device has no network connection
- **THEN** onboarding, trade creation, completion, history, deletion, scene presentation, and privacy settings remain usable

#### Scenario: Runtime dependency is audited
- **WHEN** the archived application binary is inspected
- **THEN** it contains no Cloudflare SDK, Workers endpoint, web runtime, or third-party application framework dependency

### Requirement: Private sync remains Apple-native and optional
The application SHALL use local SwiftData persistence and MAY synchronize supported records through the person’s private Apple cloud database when the signed entitlement and account are available.

#### Scenario: Private Apple sync is unavailable
- **WHEN** iCloud capability, account state, or network access is unavailable
- **THEN** local recording continues and the application does not claim successful synchronization

### Requirement: Apple intelligence is additive only
The application MAY use an available on-device Apple model or system visual-creation sheet for bounded optional wording or keepsakes, but SHALL keep deterministic product behavior authoritative.

#### Scenario: Apple intelligence is unavailable
- **WHEN** the device does not support or permit the optional Apple capability
- **THEN** all essential customer actions and factual summaries remain complete with authored deterministic output

### Requirement: Cloudflare-specific infrastructure is absent
The repository SHALL contain no Cloudflare deployment configuration, Wrangler dependency, Cloudflare deployment command, provider-origin claim, or native runtime dependency.

#### Scenario: Repository boundary is audited
- **WHEN** project files, scripts, manifests, documentation, and source are searched for Cloudflare-specific integration
- **THEN** no active Cloudflare configuration, dependency, deployment path, or product claim remains
