export const siteSummary = {
  name: "Indulge",
  url: "https://indulge.significanthobbies.com",
  tagline: "Enjoy on purpose.",
  summary:
    "A private, local-first iPhone app for keeping the pleasures you choose, reclaiming time that runs longer than intended, and making room for more of the life you want.",
  status: "Invite-only TestFlight beta preparation",
  platforms: ["iPhone"],
  capabilities: [
    "Life: a personal visual room shaped by the life directions you choose",
    "Trade: one explicit exchange between automatic time and chosen time",
    "History: a quiet record of completed choices without streak scoring"
  ],
  boundaries: [
    "No Indulge account",
    "The iPhone app has no advertising, cross-app tracking, or analytics in the journal path",
    "No Screen Time authorization or app blocking in the current beta",
    "Not medical care or addiction treatment",
    "Core data is local-first; supported signed builds may use private iCloud storage"
  ],
  links: {
    home: "https://indulge.significanthobbies.com/",
    privacy: "https://indulge.significanthobbies.com/privacy/",
    support: "https://indulge.significanthobbies.com/support/",
    terms: "https://indulge.significanthobbies.com/terms/",
    accessibility: "https://indulge.significanthobbies.com/accessibility/",
    testflight: "https://indulge.significanthobbies.com/testflight/"
  },
  lastUpdated: "2026-08-17",
  screenshots: [
    "/images/screens/onboarding.jpg",
    "/images/screens/life.jpg",
    "/images/screens/trade.jpg",
    "/images/screens/focus.jpg",
    "/images/screens/history.jpg"
  ],
  faqs: [
    {
      question: "Does Indulge block apps or use Screen Time?",
      answer: "No. This beta does not request Screen Time authorization or enforce limits."
    },
    {
      question: "Do I need an account or internet connection?",
      answer: "No account is required, and the core experience works offline."
    },
    {
      question: "Is Indulge on the App Store?",
      answer:
        "Not yet. This site will not show Apple’s App Store badge until a live apps.apple.com listing exists."
    }
  ]
} as const;
