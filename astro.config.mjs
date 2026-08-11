import { defineConfig } from "astro/config";

export default defineConfig({
  site: "https://indulge.significanthobbies.com",
  output: "static",
  trailingSlash: "ignore",
  build: {
    format: "directory",
    inlineStylesheets: "always"
  },
  vite: {
    css: { transformer: "lightningcss" },
    build: { cssMinify: "lightningcss" }
  }
});
