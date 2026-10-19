# AGENTS.md — Levela root

Cross-platform conventions for the Levela Android+iOS repo.

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