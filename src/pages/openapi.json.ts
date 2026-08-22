import { siteSummary } from "../content";

export const prerender = true;

export function GET() {
  const spec = {
    openapi: "3.1.0",
    info: {
      title: `${siteSummary.name} public API`,
      version: "1.0.0",
      description: `${siteSummary.name} — ${siteSummary.tagline}. The public web API exposes read-only agent surfaces: the agent catalog, sitemap, llms.txt, and per-page markdown alternates.`,
      contact: { name: siteSummary.name, url: siteSummary.url },
    },
    servers: [{ url: siteSummary.url }],
    tags: [{ name: "agent-surfaces", description: "Machine-readable public surfaces" }],
    paths: {
      "/api/ai": {
        get: {
          operationId: "getAgentCatalog",
          tags: ["agent-surfaces"],
          summary: "Agent catalog",
          description: "JSON inventory of public agent surfaces.",
          responses: { "200": { description: "Agent catalog", content: { "application/json": {} } } },
        },
      },
      "/llms.txt": {
        get: {
          operationId: "getLlmsTxt",
          tags: ["agent-surfaces"],
          summary: "llms.txt index",
          responses: { "200": { description: "Markdown index", content: { "text/plain": {} } } },
        },
      },
      "/sitemap.xml": {
        get: {
          operationId: "getSitemap",
          tags: ["agent-surfaces"],
          summary: "Sitemap",
          responses: { "200": { description: "XML sitemap", content: { "application/xml": {} } } },
        },
      },
      "/openapi.json": {
        get: {
          operationId: "getOpenApiSpec",
          tags: ["agent-surfaces"],
          summary: "OpenAPI specification",
          description: "This document.",
          responses: { "200": { description: "OpenAPI 3.1 spec", content: { "application/json": {} } } },
        },
      },
    },
  };
  return new Response(JSON.stringify(spec, null, 2), {
    headers: { "content-type": "application/json; charset=utf-8" },
  });
}
