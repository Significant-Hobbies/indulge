import { siteSummary } from "../content";

export const prerender = true;

export function GET() {
  const body = [
    `# ${siteSummary.name}`,
    `> ${siteSummary.summary}`,
    "",
    "## When to use this",
    "- Best fit: intentionally choosing and trading time for pleasures on iPhone with local-first privacy",
    "- Best fit: tracking completed indulgences and their life-direction trade-offs without streak scoring",
    "- Not a fit: app blocking, Screen Time enforcement, or addiction treatment",
    "- Not a fit: social habit tracking or gamified reward systems",
    "",
    "## Primary",
    `- [Product overview](${siteSummary.links.home}index.md): Canonical Markdown summary of Indulge.`,
    `- [Privacy](${siteSummary.links.privacy}): Current local-first privacy policy.`,
    `- [Support](${siteSummary.links.support}): Beta support and feedback guidance.`,
    `- [TestFlight](${siteSummary.links.testflight}): Current beta availability and testing scope.`,
    "",
    "## Developer docs",
    `- [OpenAPI spec](${siteSummary.url}/openapi.json): OpenAPI 3.1 specification for the public API`,
    `- [Agent catalog](${siteSummary.url}/api/ai): JSON inventory of public agent surfaces`,
    `- [Sitemap](${siteSummary.url}/sitemap.xml): XML sitemap of all public pages`,
    `- [This index](${siteSummary.url}/llms.txt)`,
    "",
    "## Machine surfaces",
    `- [Agent catalog](${siteSummary.url}/api/ai)`,
    `- [OpenAPI spec](${siteSummary.url}/openapi.json)`,
    `- [Sitemap](${siteSummary.url}/sitemap.xml)`,
    `- [This index](${siteSummary.url}/llms.txt)`,
    "",
    "## Product boundaries",
    ...siteSummary.boundaries.map((item) => `- ${item}`),
    ""
  ].join("\n");
  return new Response(body, { headers: { "content-type": "text/plain; charset=utf-8" } });
}
