# Indulge App Store submission draft

Prepared for invite-only TestFlight testing. Do not submit or release this build
to the App Store without a separate decision.

## Identity

- Name: Indulge
- Bundle ID: `com.significanthobbies.indulge`
- SKU: `indulge-ios-1`
- Version: `0.1.0`
- Build: `1`
- Primary language: English (U.S.)
- Primary category: Health & Fitness
- Secondary category: Lifestyle
- Copyright: `2026 Sarthak Agrawal`
- License: Apple's standard EULA
- Content rights: Indulge owns or is licensed to use the bundled artwork and app content.

## Store copy

**Subtitle**
Keep pleasure. Reclaim time.

**Promotional text**
Notice where attention escapes, keep the pleasures you choose, and trade one small pocket of automatic time for more of the life you want.

**Description**
Enjoy on purpose.

Indulge is a private, gentle way to notice where time gets pulled away and make room for something you want more. It does not ask you to quit every pleasure, chase a streak, or turn your life into a score.

Begin with a visual conversation about the activities you genuinely enjoy, the moments that run longer than intended, and the life directions you want to make room for. Your choices shape a personal living scene that carries through the app.

• Keep intentional indulgence without shame
• Make one small, explicit time trade
• Record Focus interruptions and the path back
• See daily recovery time without productivity scoring
• Keep your profile, trades, and journal private on your device
• Use the core experience offline with no account
• Explore with VoiceOver, Dynamic Type, and Reduce Motion support

Indulge is a reflective wellbeing tool, not medical care, addiction treatment, or Screen Time enforcement. If a habit is causing serious harm, consider seeking qualified professional support.

**Keywords**
focus,time,attention,habits,wellbeing,journal,intention,screen time,reflection

## URLs

- Support: `https://indulge.pages.dev/support/`
- Marketing: `https://indulge.pages.dev`
- Privacy: `https://indulge.pages.dev/privacy/`

The canonical public privacy copy is generated from `src/pages/privacy.astro`.
The product, privacy, and support routes must resolve over HTTPS before testing
invitations are sent.

## App privacy answers

- Tracking: No
- Data collected: No
- Profile, trades, Focus entries, and notes: stored locally first; private
  iCloud sync must not be declared until its development verification is complete
- Third-party advertising and analytics: none
- IDFA: not used

## Age rating draft

- Made for Kids: No
- Gambling, contests, simulated gambling, loot boxes: None
- Sexual content, profanity, horror, violence: None
- Medical or treatment claims: None
- User-generated content, messaging, unrestricted web access: None
- Alcohol or tobacco references: Infrequent/Mild, because the optional visual reflection catalog can neutrally mirror a user-selected alcohol context

Confirm the rating produced by App Store Connect's current questionnaire.

## Review notes

No Indulge login, subscription, or external hardware is required. Complete onboarding to reach the Life, Focus, Trade, and History tabs. Data saves locally first. Private iCloud sync is prepared but must be described as inactive until its signed two-device verification is recorded. Apple Screen Time enforcement is not part of this build. Optional on-device Focus suggestions and bounded reflection selection appear only on supported Apple Intelligence devices; manual classification and authored reflections are always available.

## Screenshots

- iPhone 6.9-inch portrait sequence (`1320 × 2868`): `onboarding.jpg`, `life.jpg`, `focus.jpg`, `trade.jpg`, and `history.jpg` in `artifacts/app-store/iphone-6.9`
- iPad 13-inch portrait sequence (`2064 × 2752`): `onboarding.jpg`, `life.jpg`, `focus.jpg`, `trade.jpg`, and `history.jpg` in `artifacts/app-store/ipad-13`
- Both sets use Apple-accepted dimensions, contain no alpha channel, and were captured from deterministic simulator routes
- App previews: omit for version 0.1.0
- Release: manual
