#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const productionPaths = ["Indulge", "src"];
const baselines = {
  unused: {
    files: 0,
    exports: 0,
    types: 0,
    dependencies: 0,
    devDependencies: 0,
    unlisted: 0,
    unresolved: 0
  },
  // Measured on current Indulge + landing sources; ratchet via #16.
  complexity: { violations: 6, maxCcn: 18, maxLength: 163, maxParams: 9 },
  // jscpd percentage jitters in later digits between runs.
  duplication: { clones: 1, duplicatedLines: 15, percentage: 0.22 }
};

function log(message) {
  process.stdout.write(`${message}\n`);
}

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd: projectRoot,
    encoding: "utf8",
    env: { ...process.env, ...(options.env ?? {}) },
    maxBuffer: 64 * 1024 * 1024
  });
  if (result.error) throw result.error;
  if (result.status !== 0 && !options.allowFailure) {
    process.stdout.write(result.stdout ?? "");
    process.stderr.write(result.stderr ?? "");
    throw new Error(`${command} exited with status ${result.status}`);
  }
  return {
    status: result.status ?? 1,
    stdout: result.stdout ?? "",
    stderr: result.stderr ?? ""
  };
}

function parseJson(result, label) {
  try {
    return JSON.parse(result.stdout);
  } catch (error) {
    process.stderr.write(result.stderr);
    throw new Error(`${label} did not return valid JSON`, { cause: error });
  }
}

function commandWithUvx(command, uvxArgs) {
  const probe = spawnSync(command, ["--version"], { encoding: "utf8" });
  return probe.status === 0 ? { command, prefix: [] } : { command: "uvx", prefix: uvxArgs };
}

function issueCount(issues, key) {
  return issues.reduce((sum, issue) => sum + (issue[key]?.length ?? 0), 0);
}

function failRegressions(label, observed, baseline) {
  const regressions = Object.entries(baseline).filter(([key, maximum]) => observed[key] > maximum);
  if (regressions.length > 0) {
    throw new Error(
      regressions
        .map(([key, maximum]) => `${label} ${key} regressed: ${observed[key]} > ${maximum}`)
        .join("\n")
    );
  }
  if (Object.entries(baseline).some(([key, maximum]) => observed[key] < maximum)) {
    log(`${label} improved; lower the checked-in baseline intentionally.`);
  }
}

function checkFormat() {
  run("pnpm", ["exec", "biome", "format", "."]);
  log("Landing format: biome clean. Native Swift stays on Xcode; no repo swift-format config.");
}

function checkLint() {
  run("pnpm", ["exec", "biome", "check", "."]);
  log("Landing lint: biome clean. Native compile/lint evidence stays on xcodebuild.");
}

function checkTypes() {
  run("pnpm", ["exec", "astro", "check"]);
  log("Types: astro check is the landing source of truth.");
}

function checkTests() {
  run("zsh", ["scripts/test.sh"]);
  log("Tests: scripts/test.sh / XCTest is the native source of truth.");
}

function checkCoverage() {
  run("zsh", ["scripts/test.sh"]);
  log("Coverage: the Indulge scheme gathers coverage during scripts/test.sh.");
}

function checkUnused() {
  const report = parseJson(
    run("pnpm", ["exec", "knip", "--reporter", "json", "--no-exit-code", "--no-progress"], {
      allowFailure: true
    }),
    "Knip"
  );
  const issues = report.issues ?? [];
  const observed = Object.fromEntries(
    Object.keys(baselines.unused).map((key) => [key, issueCount(issues, key)])
  );
  log(
    `Unused: files=${observed.files}, exports=${observed.exports}, types=${observed.types}, ` +
      `dependencies=${observed.dependencies}, devDependencies=${observed.devDependencies}, ` +
      `unlisted=${observed.unlisted}, unresolved=${observed.unresolved}.`
  );
  failRegressions("Unused", observed, baselines.unused);
}

function checkComplexity() {
  const lizard = commandWithUvx("lizard", ["--from", "lizard==1.23.0", "lizard"]);
  const result = run(lizard.command, [
    ...lizard.prefix,
    ...productionPaths,
    "-x",
    "**/Resources/**",
    "-x",
    "**/*.test.*",
    "--csv"
  ]);
  const rows = result.stdout
    .trim()
    .split("\n")
    .map((line) => line.match(/^(\d+),(\d+),(\d+),(\d+),(\d+),/u))
    .filter(Boolean)
    .map((match) => match.slice(1).map(Number));
  const observed = {
    functions: rows.length,
    nloc: rows.reduce((sum, row) => sum + row[0], 0),
    violations: rows.filter((row) => row[1] > 15 || row[4] > 100 || row[3] > 7).length,
    maxCcn: Math.max(0, ...rows.map((row) => row[1])),
    maxLength: Math.max(0, ...rows.map((row) => row[4])),
    maxParams: Math.max(0, ...rows.map((row) => row[3]))
  };
  log(
    `Complexity: ${observed.functions} functions, ${observed.nloc} NLOC, ` +
      `${observed.violations} violations; max CCN ${observed.maxCcn}, ` +
      `max length ${observed.maxLength}, max params ${observed.maxParams}.`
  );
  failRegressions("Complexity", observed, baselines.complexity);
}

function checkDuplication() {
  const outputDirectory = mkdtempSync(join(tmpdir(), "indulge-jscpd-"));
  run("pnpm", [
    "exec",
    "jscpd",
    ...productionPaths,
    "--format",
    "javascript,typescript,swift",
    "--min-lines",
    "8",
    "--min-tokens",
    "60",
    "--mode",
    "strict",
    "--ignore",
    "**/Resources/**,**/*.test.*,**/node_modules/**,**/dist/**",
    "--reporters",
    "json",
    "--output",
    outputDirectory,
    "--silent",
    "--no-tips"
  ]);
  const observed = JSON.parse(readFileSync(join(outputDirectory, "jscpd-report.json"), "utf8"))
    .statistics.total;
  log(
    `Duplication: ${observed.duplicatedLines}/${observed.lines} lines ` +
      `(${observed.percentage.toFixed(4)}%), ${observed.clones} groups across ${observed.sources} files.`
  );
  failRegressions("Duplication", observed, baselines.duplication);
}

function checkCycles() {
  const report = parseJson(
    run(
      "pnpm",
      ["exec", "knip", "--cycles", "--reporter", "json", "--no-exit-code", "--no-progress"],
      { allowFailure: true }
    ),
    "Knip cycle analysis"
  );
  const cycles = (report.issues ?? []).flatMap((issue) => issue.cycles ?? []);
  if (cycles.length > 0) {
    throw new Error(`Landing dependency cycles detected: ${cycles.length}`);
  }
  log("Cycles: zero landing import cycles; native target graph stays on Xcode.");
}

const checks = {
  complexity: checkComplexity,
  coverage: checkCoverage,
  cycles: checkCycles,
  duplication: checkDuplication,
  format: checkFormat,
  lint: checkLint,
  tests: checkTests,
  types: checkTypes,
  unused: checkUnused
};

const selected = process.argv[2];
const allChecks = ["format", "lint", "types", "unused", "complexity", "duplication", "cycles"];

try {
  if (selected === "all") {
    for (const name of allChecks) checks[name]();
  } else if (Object.hasOwn(checks, selected)) {
    checks[selected]();
  } else {
    throw new Error(`Usage: check-code-health.mjs <all|${Object.keys(checks).join("|")}>`);
  }
} catch (error) {
  process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
  process.exit(1);
}
