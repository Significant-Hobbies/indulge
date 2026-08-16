# Indulge agent instructions

Follow `/Users/sarthak/Desktop/fleet/AGENTS.md` and the project truth in
`PROJECT_STATUS.md`, `PRODUCT.md`, and `DESIGN.md`.

## Commands

- Generate the Xcode project: `xcodegen generate`
- Build the app: `./scripts/build.sh`
- Native tests: `./scripts/test.sh` or `pnpm test`
- Landing types: `pnpm typecheck` (`astro check`)
- Quality inventory: `pnpm format:check`, `pnpm lint`, `pnpm quality`
- Validate the active change: `openspec validate build-indulge-visual-proof --strict`

## Native boundaries

- The primary product is a native iPhone and iPad app built with SwiftUI and RealityKit.
- Keep the animated world in RealityKit and native controls/accessibility in
  SwiftUI.
- Add no production dependency without explicit approval.
- Keep visual-proof data deterministic, offline, and free of entitlements.
- Preserve the non-moralizing product voice and Reduce Motion alternative.
