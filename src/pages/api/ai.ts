import { siteSummary } from "../../content";

export const prerender = true;

export function GET() {
  return new Response(
    JSON.stringify(
      {
        name: siteSummary.name,
        version: "1",
        url: siteSummary.url,
        llms: `${siteSummary.url}/llms.txt`,
        llmsFull: null,
        sitemap: `${siteSummary.url}/sitemap.xml`,
        markdown: { suffix: ".md", negotiation: true },
        openapi: `${siteSummary.url}/openapi.json`,
        surfaces: [
          { id: "home", url: "/", md: "/index.md", kind: "static" },
          { id: "privacy", url: "/privacy/", kind: "static" },
          { id: "support", url: "/support/", kind: "static" },
          { id: "terms", url: "/terms/", kind: "static" },
          { id: "accessibility", url: "/accessibility/", kind: "static" },
          { id: "testflight", url: "/testflight/", kind: "static" }
        ],
        auth: { public: true, notes: "No product account." },
        schema_version: "1.0",
        generated_at: `${siteSummary.lastUpdated}T00:00:00Z`,
        product: siteSummary
      },
      null,
      2
    ),
    {
      headers: { "content-type": "application/json; charset=utf-8" }
    }
  );
}
