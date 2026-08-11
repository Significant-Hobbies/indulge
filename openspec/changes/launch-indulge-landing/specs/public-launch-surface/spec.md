## Purpose

Provide a trustworthy public home where prospective testers can understand Indulge, inspect real product evidence, reach support and legal information, and follow the truthful TestFlight path.

## ADDED Requirements

### Requirement: Hero explains the product without scrolling
The public home SHALL identify Indulge, explain its non-punitive time-trade outcome in plain language, show real product imagery, and expose one primary next action in the first viewport.

#### Scenario: First visit on a wide screen
- **WHEN** a visitor opens the home page on a wide viewport
- **THEN** the visitor sees the Indulge identity, the retained-pleasure and reclaimed-time promise, an owned app scene, and one primary action without scrolling

#### Scenario: First visit on a narrow screen
- **WHEN** a visitor opens the home page at 390 CSS pixels wide
- **THEN** the same identity, promise, real product evidence, and primary action remain legible without horizontal scrolling

### Requirement: TestFlight availability is represented truthfully
The public surface SHALL link directly to TestFlight only when a valid Apple testing URL is configured and SHALL otherwise explain that the beta is currently invite-only without presenting a false enrollment action.

#### Scenario: Public TestFlight URL is absent
- **WHEN** the site is built without a public TestFlight URL
- **THEN** the primary action leads to an honest beta-status page that explains the current invite-only state

#### Scenario: Public TestFlight URL is configured
- **WHEN** the site is built with a valid public TestFlight URL
- **THEN** the primary action opens that Apple-hosted URL and clearly identifies the destination

### Requirement: Product claims are demonstrated with owned evidence
The public surface SHALL explain Life, Focus, Trade, and History using current owned app imagery and SHALL NOT invent testimonials, prices, benchmarks, clinical outcomes, or capabilities that are not shipped.

#### Scenario: Visitor reviews how Indulge works
- **WHEN** a visitor reaches the product explanation
- **THEN** each primary surface is paired with an accurate description and current Indulge screenshot or scene asset

### Requirement: Visitors can self-qualify
The public surface SHALL state who Indulge is for, who it is not for, and that it is a reflective wellbeing tool rather than medical care, addiction treatment, or compulsory blocking.

#### Scenario: Visitor evaluates fit
- **WHEN** a visitor reaches the fit section
- **THEN** the visitor can distinguish intentional time trading from abstinence, scoring, punishment, clinical care, and externally imposed control

### Requirement: Required trust and legal routes are public
The site SHALL expose stable HTTPS routes for privacy, support, terms, accessibility, and beta status, and SHALL link those routes from the home page and footer.

#### Scenario: App Store reviewer opens privacy and support URLs
- **WHEN** an App Store reviewer requests `/privacy` or `/support`
- **THEN** each route returns a readable successful response without authentication or client-side JavaScript

#### Scenario: Visitor opens legal navigation
- **WHEN** a visitor follows footer legal links
- **THEN** privacy, terms, accessibility, and support content is reachable and identifies its effective or updated date where applicable

### Requirement: Privacy statements match the shipped build
The privacy page SHALL describe local device storage, optional Apple-native features, private CloudKit preparation boundaries, data deletion, transient TestFlight diagnostics where applicable, and the absence of advertising or cross-app tracking without overstating unavailable verification.

#### Scenario: Visitor reviews data handling
- **WHEN** a visitor reads the privacy page
- **THEN** the page distinguishes local app data, optional Apple services, TestFlight crash and usage diagnostics, and information the developer does not collect

### Requirement: The surface is accessible and responsive
The public surface SHALL use semantic structure, keyboard-visible controls, sufficient contrast, responsive media, reduced-motion behavior, and readable layouts at 390, 768, and 1440 CSS pixels.

#### Scenario: Reduced motion is requested
- **WHEN** a visitor enables reduced motion
- **THEN** every product explanation and state remains understandable without scroll-linked or animated transitions

#### Scenario: Keyboard-only navigation
- **WHEN** a visitor navigates using only a keyboard
- **THEN** all interactive elements receive a visible focus state in logical document order

### Requirement: Agents can read product truth without JavaScript
The public surface SHALL publish `llms.txt`, public Markdown, and `/api/ai` containing concise product, testing, privacy, support, and canonical-link information.

#### Scenario: Agent requests discovery content
- **WHEN** an agent requests `/llms.txt`, the public Markdown route, or `/api/ai`
- **THEN** it receives a successful text or JSON response that describes Indulge accurately and links to canonical public routes

### Requirement: Production deployment is reproducible and guarded
The repository SHALL provide a deterministic static build, CI validation, a single Cloudflare Pages target, and a deploy command that fails unless clean synchronized `main` and current-main CI satisfy the Fleet deploy guard.

#### Scenario: Deployment is attempted from a dirty tree
- **WHEN** the production deploy command runs with uncommitted changes
- **THEN** deployment stops before uploading assets

#### Scenario: Valid production deployment completes
- **WHEN** clean synchronized `main` has green current-main CI and the configured Cloudflare target exists
- **THEN** the built site is uploaded to the single Indulge Pages project and its required public routes are smoke-tested
