import { siteSummary } from "../content";

export const prerender = true;

export function GET() {
  const body = [
    `# ${siteSummary.name}`,
    `> ${siteSummary.summary}`,
    "",
    "## Primary",
    `- [Product overview](${siteSummary.links.home}index.md): Canonical Markdown summary of Indulge.`,
    `- [Privacy](${siteSummary.links.privacy}): Current local-first privacy policy.`,
    `- [Support](${siteSummary.links.support}): Beta support and feedback guidance.`,
    `- [TestFlight](${siteSummary.links.testflight}): Current beta availability and testing scope.`,
    "",
    "## Product boundaries",
    ...siteSummary.boundaries.map((item) => `- ${item}`),
    ""
  ].join("\n");
  return new Response(body, { headers: { "content-type": "text/plain; charset=utf-8" } });
}
