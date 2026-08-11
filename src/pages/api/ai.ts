import { siteSummary } from "../../content";

export const prerender = true;

export function GET() {
  return new Response(JSON.stringify({
    schema_version: "1.0",
    generated_at: `${siteSummary.lastUpdated}T00:00:00Z`,
    product: siteSummary
  }, null, 2), {
    headers: { "content-type": "application/json; charset=utf-8" }
  });
}
