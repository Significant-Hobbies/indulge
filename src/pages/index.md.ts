import { siteSummary } from "../content";

export const prerender = true;

export function GET() {
  const lines = [
    `# ${siteSummary.name}`,
    "",
    `> ${siteSummary.tagline}`,
    "",
    siteSummary.summary,
    "",
    `Status: ${siteSummary.status}.`,
    "",
    "## Product areas",
    "",
    ...siteSummary.capabilities.map((item) => `- ${item}`),
    "",
    "## Important boundaries",
    "",
    ...siteSummary.boundaries.map((item) => `- ${item}`),
    "",
    "## Canonical links",
    "",
    ...Object.entries(siteSummary.links).map(([name, url]) => `- ${name}: ${url}`),
    "",
    `Last updated: ${siteSummary.lastUpdated}`,
    ""
  ];
  return new Response(lines.join("\n"), { headers: { "content-type": "text/markdown; charset=utf-8" } });
}
