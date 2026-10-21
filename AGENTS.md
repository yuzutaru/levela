# AGENTS.md — Levela root

Cross-platform conventions for the Levela Android+iOS repo.

## App flow (both platforms)
1. **Splash** (launch) → guest taps **Continue as a guest**.
2. **Onboarding** (seven steps) → final Next persists a guest-owned profile.
3. **Main menu** — the bottom-navigation home (Today · Nutrition · Train ·
   Profile). Today is a real dashboard in its own module; the other destinations
   are still placeholders. A returning user with a saved profile skips onboarding
   and lands here straight after the splash.
Each platform has its own module layout, design system, and DI wiring; see the
per-platform guides below.

## Repository map
- `android/` — Kotlin + Jetpack Compose app; modules `:app`, `:design`,
  `:profile`, `:onboarding`, `:splash`, `:mainmenu`.
- `ios/` — SwiftUI app + local Swift packages `Design`, `Onboarding`, `Splash`,
  `Profile`, `MainMenu`.
- `assets/` — single-source-of-truth contracts shared by both platforms:
  `app-icon/`, `theme/` (`theme-contract.json` + `THEME_COLORS.md`),
  `splash/`, `onboarding/` (each has its own `README.md`),
  plus `sync/` — the not-yet-implemented sync contract.
- `scripts/` — icon generator, the theme/icon/flow parity verifiers, and the
  tracked git hooks.

## Commit convention
Enforce platform-scoped subject in commit messages
(`feat(android)` / `fix(android)` / `feat(ios)` / `fix(ios)` etc.);
the `scripts/hooks/commit-msg` hook validates this and the
`scripts/hooks/pre-commit` hook enforces the platform split.
Both hooks are activated once per clone with
`./scripts/install-hooks.sh`.

## Platform separation
The `pre-commit` hook (`scripts/hooks/pre-commit`) rejects any commit that
stages changes under both `android/` and `ios/`. Keep Android and iOS changes
in separate commits, each with its own scope tag.

## Hooks (per clone)
```sh
./scripts/install-hooks.sh
```
This installs `pre-commit` (platform split) and `commit-msg` (scope validation)
into `git config core.hooksPath`.

## Reference per platform
- `android/AGENTS.md` — agent guide for the Android module.
- `ios/AGENTS.md` — agent guide for the iOS app target.
- `android/app/src/test/` and `ios/LevelaTests/` — unit test locations for
  app-level use cases and view models (see each guide for inventory).